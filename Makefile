BASE_DIR         = $(shell pwd)
ERLANG_BIN       = $(shell dirname $(shell which erl))
GIT_VERSION      = $(shell git describe --tags)
OVERLAY_VARS    ?=
REBAR ?= $(BASE_DIR)/rebar3
BUILD_CONF ?= $(BASE_DIR)/_build/default/rel/vernemq/etc/vernemq.conf

$(if $(ERLANG_BIN),,$(warning "Warning: No Erlang found in your path, this will probably not work"))


all: compile

compile:
	$(REBAR) $(PROFILE) compile


rpi32: PROFILE = as rpi32
rpi32: rel


##
## Release targets
##
rel:
	cat vars.config > vars.generated
	echo "{app_version, \"${GIT_VERSION}\"}." >> vars.generated
ifeq ($(OVERLAY_VARS),)
else
	cat $(OVERLAY_VARS) >> vars.generated
endif
	$(REBAR) $(PROFILE) release
	grep -v "include conf" $(BUILD_CONF) > $(BUILD_CONF).new
	mv $(BUILD_CONF).new $(BUILD_CONF)

##
## Developer targets
##
##  devN - Make a dev build for node N
dev% :
	./gen_dev $@ vars/dev_vars.config.src vars/$@_vars.config
	cat vars/$@_vars.config > vars.generated
	(./rebar3 as $@ release)

.PHONY: all compile rpi32 rel
export OVERLAY_VARS
