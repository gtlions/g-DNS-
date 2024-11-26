BUILD_DIR=$(CURDIR)/build
ISUPX:=$(shell which upx > /dev/null 2>&1 ; echo $$?)
RELEASE_BIN:=gdnslookup

## help-show : Show this help.
help-show: Makefile
	@printf "Usage: make [target] [VARIABLE=value]\nTargets:\n"
	@sed -n 's/^## //p' $< | awk 'BEGIN {FS = ":"}; { if(NF>1 && $$2!="") printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 ; else printf "%40s\n", $$1};'
	@printf "Variables:\n"
	@grep -E "^[A-Za-z0-9_]*\?=" $< | awk 'BEGIN {FS = "\\?="}; { printf "  \033[36m%-25s\033[0m  Default values: %s\n", $$1, $$2}'

## check-go: Check go module depend. 检查并更新模块依赖.
.PHONY: check-go
check-go:
	$(info Step. 检查并更新模块依赖)
	@go mod tidy

## binary: Run goalng build. 编译二进制可执行程序.
.PHONY: binary
binary: check-go
	$(info Step. 编译二进制可执行程序)
	@rm -rf $(BUILD_DIR)/$(RELEASE_BIN)
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -ldflags '-extldflags "-static -s -w"' -o $(BUILD_DIR)/$(RELEASE_BIN)
	@if [ 0 -eq $(ISUPX) ] ; then \
		upx -9 $(BUILD_DIR)/$(RELEASE_BIN) ; \
	fi

## binaryall: Run goalng build. 编译跨平台二进制可执行程序.
.PHONY: binaryall
binaryall: check-go
	$(info Step. 编译跨平台二进制可执行程序)
	@rm -rf $(BUILD_DIR)/$(RELEASE_BIN).*
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -ldflags '-extldflags "-static -s -w"' -o $(BUILD_DIR)/$(RELEASE_BIN).linux
	@CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -a -ldflags '-extldflags "-static -s -w"' -o $(BUILD_DIR)/$(RELEASE_BIN).amd64.osx
	@CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -a -ldflags '-extldflags "-static -s -w"' -o $(BUILD_DIR)/$(RELEASE_BIN).arm64.osx
	@CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -a -ldflags '-extldflags "-static -s -w"' -o $(BUILD_DIR)/$(RELEASE_BIN).win
	@if [ 0 -eq $(ISUPX) ] ; then \
		upx -9 $(BUILD_DIR)/$(RELEASE_BIN).linux ; \
		upx -9 $(BUILD_DIR)/$(RELEASE_BIN).osx.amd64.osx ; \
		upx -9 $(BUILD_DIR)/$(RELEASE_BIN).osx.arm64.osx ; \
		upx -9 $(BUILD_DIR)/$(RELEASE_BIN).win ; \
	fi
