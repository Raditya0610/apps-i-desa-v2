package services

import (
	"errors"

	"Apps-I_Desa_Backend/dtos"
	"Apps-I_Desa_Backend/models"
	"Apps-I_Desa_Backend/repositories"
	"github.com/gofiber/fiber/v2/log"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type UserService struct {
	userRepo    *repositories.UserRepository
	villageRepo *repositories.VillageRepository
}

func NewUserService(
	userRepo *repositories.UserRepository,
	villageRepo *repositories.VillageRepository,
) *UserService {
	return &UserService{
		userRepo:    userRepo,
		villageRepo: villageRepo,
	}
}

func (s *UserService) Register(request *dtos.RegisterRequest) (*dtos.MessageResponse, error) {
	// Check if email already exists
	existingUser, err := s.userRepo.FindByUsername(request.Username)
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		log.Error("Database error: ", err)
		return nil, errors.New("failed to find existing user")
	}

	if existingUser != nil {
		log.Warn("Username already registered: ", request.Username)
		return nil, errors.New("username already registered")
	}

	// Hash the password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(request.Password), bcrypt.DefaultCost)
	if err != nil {
		log.Error("Error hashing password: ", err)
		return nil, errors.New("error hashing password")
	}

	// Validate village ID
	err = s.villageRepo.FindVillageByID(&request.VillageID)
	if err != nil {
		log.Error("Village not found: ", request.VillageID, " - Error: ", err)
		return nil, errors.New("village not found")
	}

	// Create new user
	user := &models.User{
		Username:  request.Username,
		Password:  string(hashedPassword),
		VillageID: request.VillageID,
	}

	tx := s.userRepo.BeginTransaction()
	defer tx.Rollback()

	err = s.userRepo.CreateWithTx(tx, user)
	if err != nil {
		log.Error("Error creating user: ", err)
		return nil, errors.New("failed to create user")
	}

	// Commit the transaction
	if err := tx.Commit().Error; err != nil {
		log.Error("Error committing transaction: ", err)
		return nil, errors.New("failed to commit transaction")
	}

	return &dtos.MessageResponse{
		Message: "User registered successfully",
	}, nil
}

func (s *UserService) ChangePassword(username string, req *dtos.ChangePasswordRequest) (*dtos.MessageResponse, error) {
	// Look up the acting user by username, not by village. A village can have more
	// than one account, and FindByVillageID().First() returned an arbitrary one —
	// so a user changing their own password was checked against, and could have
	// overwritten, someone else's credentials. The old-password check then failed
	// with a 401 even when the password was correct.
	user, err := s.userRepo.FindByUsername(username)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("user not found")
		}
		return nil, errors.New("failed to find user")
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.OldPassword)); err != nil {
		return nil, errors.New("old password is incorrect")
	}

	hashed, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		return nil, errors.New("error hashing password")
	}

	tx := s.userRepo.BeginTransaction()
	defer tx.Rollback()

	if err := s.userRepo.UpdatePassword(tx, user.Username, string(hashed)); err != nil {
		return nil, errors.New("failed to update password")
	}

	if err := tx.Commit().Error; err != nil {
		return nil, errors.New("failed to commit transaction")
	}

	return &dtos.MessageResponse{Message: "Password changed successfully"}, nil
}
