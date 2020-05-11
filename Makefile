#
# Makefile for the Buy A Pi UPS HAT Monitor.
#
# Development by Carl J. Nobile
#

PREFIX		= $(shell pwd)
BASE_DIR	= $(shell echo $${PWD\#\#*/})
BIN_DIR		= /usr/local/bin
LOGS_DIR        = $(PREFIX)/logs
INIT_DIR	= /etc/init.d/
RM_REGEX        = '(^.*.pyc$$)|(^.*~$$)|(.*\#$$)'
RM_CMD          = find $(PREFIX) -regextype posix-egrep -regex $(RM_REGEX) \
                  -exec rm {} \;
SRC_DIR		= scripts
DEF_DELAY	= 600

#----------------------------------------------------------------------
all	: tar

#----------------------------------------------------------------------
tar	: clean
	@(cd ..; tar -czvf ${BASE_DIR}-${VERSION}.tar.gz --exclude=".git" \
          ${BASE_DIR})

#----------------------------------------------------------------------
install-shell:
	install -d $(BIN_DIR)
	install -b -m 755 $(SRC_DIR)/ups.sh $(BIN_DIR)
	@sed 's/<SCRIPT_HERE>/"ups.sh"/' $(SRC_DIR)/ups.template > \
             $(SRC_DIR)/ups.tmp
	@sed 's/<OPTIONS_HERE>/""/' $(SRC_DIR)/ups.tmp > $(SRC_DIR)/ups
	@rm -f $(SRC_DIR)/ups.tmp
	install -m 755 $(SRC_DIR)/ups $(INIT_DIR)
	rm -f $(SRC_DIR)/ups
	update-rc.d ups defaults
	/etc/init.d/ups start

install-py:
	install -d $(BIN_DIR)
	install -b -m 755 scripts/buy_a_pi_ups.py $(BIN_DIR)
	@sed 's/<SCRIPT_HERE>/"buy_a_pi_ups.py"/' $(SRC_DIR)/ups.template > \
             $(SRC_DIR)/ups.tmp
	@sed 's/<OPTIONS_HERE>/"--delay=$(DEF_DELAY)"/' $(SRC_DIR)/ups.tmp > \
             $(SRC_DIR)/ups
	@rm -f $(SRC_DIR)/ups.tmp
	install -m 755 scripts/ups $(INIT_DIR)
	rm -f $(SRC_DIR)/ups
	update-rc.d ups defaults
	/etc/init.d/ups start

clean	:
	$(shell $(RM_CMD))

clobber : clean
	@rm -f $(LOGS_DIR)/*.log*
