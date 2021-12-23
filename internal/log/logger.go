package log

import (
	"go.uber.org/zap"
)

var baseLogger *zap.Logger

// Logger is the logger instance exposed by this package
var Logger *zap.SugaredLogger

// Init initializes the baseLogger
func init() {
	baseLogger, _ = zap.NewProduction(
		zap.AddStacktrace(zap.PanicLevel),
		zap.WithCaller(false))
	Logger = baseLogger.Sugar()
}

// Info creates an information-level log message
func Info(msg string, keysAndValues ...interface{}) {
	Logger.Infow(msg, keysAndValues...)
}

// Warn creates a warning-level log message
func Warn(msg string, keysAndValues ...interface{}) {
	Logger.Warnw(msg, keysAndValues...)
}

// Debug creates a debug-level log message
func Debug(msg string, keysAndValues ...interface{}) {
	Logger.Debugw(msg, keysAndValues...)
}

// Error creates an error-level log message
func Error(msg string, keysAndValues ...interface{}) {
	Logger.Errorw(msg, keysAndValues...)
}

// Flush flushes the log buffer
func Flush() {
	if baseLogger != nil {
		baseLogger.Sync()
	}
}
