# Negaalpha search
# usage: make -f ai/negaalpha.mk DIR=blokusfs_dir [DEPTH=N]

.SILENT:

ifndef DIR
$(error Please set DIR= parameter)
endif

DEPTH := 2
depth-1 := $(word $(DEPTH), 0 1 2 3 4 5 6 7 8 9)

ifeq ($(MAKELEVEL), $(depth-1))

negaalpha: $(DIR)
	awk 'BEGIN{getline < "$(RESULT)"; b=$$3; x=-99999} {v=-$$1;if(x<v){x=v;if(b<=x){exit 0}}} END{print x > "$(RESULT)"}' $(DIR)/*/value || cp $(DIR)/value $(RESULT)

else

ifeq ($(MAKELEVEL), 0)
RESULT := $(shell mktemp)
$(shell echo -99999 -99999 99999 >$(RESULT))
endif

tempfile := $(shell mktemp)
subdirs := $(wildcard $(DIR)/????)

.PHONY: negaalpha $(subdirs)

negaalpha: $(subdirs)
	rm $(tempfile)
ifeq ($(words $(subdirs)), 0)
	cp $(DIR)/value $(RESULT)
endif
ifeq ($(MAKELEVEL), 0)
	cat $(RESULT) 1>&2
	awk '{print $$4}' $(RESULT)
	rm $(RESULT)
endif

$(subdirs):
	awk '{print -99999,-$$3,-$$2}' $(RESULT) >$(tempfile)
	-$(MAKE) -f ai/negaalpha.mk DIR=$@ RESULT=$(tempfile) >/dev/null
	awk 'BEGIN{getline < "$(tempfile)"; v=-$$1} {print v<$$1?$$1:v, v<$$2?$$2:v, $$3, v<=$$1?$$4:"$(@F)" >"$(RESULT)"; if ($$3<=v) {system("rm $(tempfile)"); exit 1} }' $(RESULT)

endif
