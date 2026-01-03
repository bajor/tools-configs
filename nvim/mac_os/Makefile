# Sync nvim config to tools-configs repo

TOOLS_REPO := /Users/m/repos/tools-configs
TARGET_DIR := $(TOOLS_REPO)/nvim/mac_os
SOURCE_DIR := /Users/m/.config/nvim

.PHONY: sync

sync:
	@echo "Cleaning $(TARGET_DIR)..."
	rm -rf $(TARGET_DIR)/*
	@echo "Copying config to $(TARGET_DIR)..."
	rsync -av --exclude='.git' --exclude='.DS_Store' --exclude='.claude' $(SOURCE_DIR)/ $(TARGET_DIR)/
	@echo "Committing and pushing..."
	cd $(TOOLS_REPO) && git add -A && git commit -m "sync nvim/mac_os config" && git push
	@echo "Done!"
