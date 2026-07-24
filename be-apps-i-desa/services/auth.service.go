package services

import (
	"errors"
	"os"
	"time"

	"Apps-I_Desa_Backend/dtos"
	"Apps-I_Desa_Backend/models"
	"Apps-I_Desa_Backend/repositories"
	"github.com/gofiber/fiber/v2/log"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type AuthService struct {
	userRepo    *repositories.UserRepository
	villageRepo *repositories.VillageRepository
}

func NewAuthService(userRepo *repositories.UserRepository, villageRepo *repositories.VillageRepository) *AuthService {
	return &AuthService{userRepo: userRepo, villageRepo: villageRepo}
}

func (s *AuthService) Login(request *dtos.LoginRequest) (*dtos.LoginResponse, error) {
	// Find user by username
	user, err := s.userRepo.FindByUsername(request.Username)
	if errors.Is(err, gorm.ErrRecordNotFound) {
		log.Error("User not found: ", request.Username)
		return nil, errors.New("user not found")
	} else if err != nil {
		log.Error("Database error: ", err)
		return nil, errors.New("failed to retrieve user")
	}

	// Verify password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(request.Password)); err != nil {
		log.Error("Error compare", err)
		return nil, errors.New("invalid username or password")
	}

	// New session per login: overwriting session_id invalidates whatever
	// token an already-logged-in device is holding — that's the mechanism
	// behind "only one device at a time". Written before the token is
	// generated so the claim and the stored value always agree.
	sessionID := uuid.New()
	tx := s.userRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.userRepo.UpdateSessionID(tx, user.Username, sessionID); err != nil {
		log.Error("Error updating session ID: ", err)
		return nil, errors.New("failed to start session")
	}
	if err := tx.Commit().Error; err != nil {
		log.Error("Error committing session update: ", err)
		return nil, errors.New("failed to start session")
	}

	// Generate JWT token
	token, err := generateJWTToken(user, sessionID)
	if err != nil {
		log.Error("Error generating token: ", err)
		return nil, errors.New("failed to generate token")
	}

	// Display-only lookup for the dashboard greeting. Never fails the login
	// over this — the token is already valid and usable even if this lookup
	// has a problem, so it just logs and leaves VillageName blank.
	villageName := ""
	if village, err := s.villageRepo.GetVillageByID(user.VillageID); err != nil {
		log.Error("Error fetching village name: ", err)
	} else {
		villageName = village.Name
	}

	return &dtos.LoginResponse{
		Token:       token,
		Message:     "Login successful",
		VillageID:   user.VillageID.String(),
		VillageName: villageName,
	}, nil
}

// Logout invalidates the account's current session immediately — without
// this, a token captured before logout (e.g. from browser history/cache)
// would stay valid until its 1-hour expiry despite the user having logged
// out. username is empty when called without a valid token (JWTAuth already
// rejected it, so there is no session left to invalidate anyway).
func (s *AuthService) Logout(username string) *dtos.MessageResponse {
	if username != "" {
		tx := s.userRepo.BeginTransaction()
		defer tx.Rollback()
		if err := s.userRepo.UpdateSessionID(tx, username, uuid.New()); err != nil {
			log.Error("Error invalidating session on logout: ", err)
		} else if err := tx.Commit().Error; err != nil {
			log.Error("Error committing session invalidation: ", err)
		}
	}

	return &dtos.MessageResponse{
		Message: "Logout successful!",
	}
}

// generateJWTToken creates a new JWT token for the authenticated user
func generateJWTToken(user *models.User, sessionID uuid.UUID) (string, error) {
	// Set expiration time
	expTime := time.Now().Add(1 * time.Hour)

	// Create claims
	// "username" is carried so mutations can be attributed in the activity log.
	// "session_id" is compared against the account's stored SessionID on every
	// request — see JWTAuth middleware — to enforce single-device login.
	claims := jwt.MapClaims{
		"village":    user.VillageID,
		"username":   user.Username,
		"session_id": sessionID.String(),
		"exp":        expTime.Unix(),
	}

	// Create token with claims
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	// Generate signed token
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		return "", errors.New("JWT secret not configured")
	}
	tokenString, err := token.SignedString([]byte(secret))
	if err != nil {
		return "", err
	}

	return tokenString, nil
}
