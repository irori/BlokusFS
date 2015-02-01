# Negamax search
# usage: make -f ai/negamax.mk DIR=blokusfs_dir [DEPTH=N]

.SILENT:

ifndef DIR
$(error Please set DIR= parameter)
endif

DEPTH := 2
depth-1 := $(word $(DEPTH), 0 1 2 3 4 5 6 7 8 9)

ifeq ($(MAKELEVEL), $(depth-1))

negamax: $(DIR)
	(sort -n $(DIR)/*/value || cat $(DIR)/value) |head -n1

else

subdirs := $(wildcard $(DIR)/????)
.PHONY: negamax $(subdirs)

ifeq ($(words $(subdirs)), 0)

negamax:
	cat $(DIR)/value

else

tempfile := $(shell mktemp)

negamax: $(subdirs)
ifeq ($(MAKELEVEL), 0)
	sort -r -n $(tempfile) |head -n1 |cut -f2
else
	sort -r -n $(tempfile) |head -n1 |sed -e 's/^/-/' -e 's/^--//'
endif
	rm $(tempfile)

$(subdirs):
ifeq ($(MAKELEVEL), 0)
	$(MAKE) DIR=$@ -f ai/negamax.mk |sed 's/$$/	$(@F)/' >>$(tempfile)
else
	$(MAKE) DIR=$@ -f ai/negamax.mk >>$(tempfile)
endif

endif

endif
