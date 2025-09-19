# Makefile for notes visualization module tests
# Uses mini.test for comprehensive testing

.PHONY: test test-plot test-utils test-init test-all setup-deps clean help

# Default target
test: test-all

# Individual test targets
test-plot:
	@echo "🧪 Running plot module tests..."
	@nvim --headless -u scripts/minimal_init.lua -c "lua require('mini.test').execute(require('tests.test_notes_plot'))" -c "qa!"

test-utils:
	@echo "🔧 Running utils module tests..."  
	@nvim --headless -u scripts/minimal_init.lua -c "lua require('mini.test').execute(require('tests.test_notes_utils'))" -c "qa!"

test-init:
	@echo "⚙️ Running init module tests..."
	@nvim --headless -u scripts/minimal_init.lua -c "lua require('mini.test').execute(require('tests.test_notes_init'))" -c "qa!"

# Run all tests
test-all:
	@echo "🚀 Running all notes module tests..."
	@echo "======================================="
	@$(MAKE) test-plot
	@echo ""
	@$(MAKE) test-utils  
	@echo ""
	@$(MAKE) test-init
	@echo ""
	@echo "✅ All tests completed!"

# Interactive test mode (opens in Neovim)
test-interactive:
	@echo "🖥️ Opening interactive test mode..."
	@nvim -u scripts/minimal_init.lua -c "lua require('mini.test').execute(require('tests.test_notes_plot'))"

# Set up dependencies
setup-deps:
	@echo "📦 Setting up test dependencies..."
	@mkdir -p deps
	@if [ ! -d "deps/mini.nvim" ]; then \
		echo "Cloning mini.nvim..."; \
		git clone https://github.com/echasnovski/mini.nvim deps/mini.nvim; \
	else \
		echo "mini.nvim already exists"; \
	fi
	@mkdir -p /tmp/test_notebooks
	@echo "✅ Dependencies ready!"

# Test specific function or module
test-function:
	@read -p "Enter test pattern (e.g., histogram, pie_chart): " pattern; \
	nvim --headless -u scripts/minimal_init.lua -c "lua require('mini.test').execute(require('tests.test_notes_plot'), {filter = '$$pattern'})" -c "qa!"

# Clean test artifacts
clean:
	@echo "🧹 Cleaning test artifacts..."
	@rm -rf /tmp/test_notebooks
	@echo "✅ Clean complete!"

# Lint the test files
lint-tests:
	@echo "🔍 Linting test files..."
	@for file in tests/test_*.lua; do \
		echo "Checking $$file..."; \
		luacheck "$$file" --globals vim MiniTest || true; \
	done

# Show test coverage (manual inspection)
coverage:
	@echo "📊 Test coverage analysis:"
	@echo "Plot module functions:"
	@grep -n "^function M\." lua/notes/plot.lua || true
	@echo ""
	@echo "Utils module functions:"  
	@grep -n "^function M\." lua/notes/utils.lua || true
	@echo ""
	@echo "Init module functions:"
	@grep -n "^function M\." lua/notes/init.lua || true

# Run specific test suite with verbose output
verbose:
	@read -p "Enter test file (plot/utils/init): " module; \
	nvim --headless -u scripts/minimal_init.lua -c "lua MiniTest = require('mini.test'); MiniTest.execute(require('tests.test_notes_$$module'), {verbose = true})" -c "qa!"

# Help target
help:
	@echo "📖 Available targets:"
	@echo "  test              - Run all tests (default)"
	@echo "  test-plot         - Test plotting functions"
	@echo "  test-utils        - Test utility functions"
	@echo "  test-init         - Test main module and setup"
	@echo "  test-all          - Run all test suites"
	@echo "  test-interactive  - Open tests in Neovim"
	@echo "  test-function     - Test specific function pattern"
	@echo "  setup-deps        - Set up mini.nvim dependency"
	@echo "  clean             - Clean test artifacts"
	@echo "  lint-tests        - Lint test files"
	@echo "  coverage          - Show function coverage"
	@echo "  verbose           - Run tests with verbose output"
	@echo "  help              - Show this help"

# Ensure deps are set up before running tests
test-plot test-utils test-init test-all: | setup-deps
