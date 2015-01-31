.SILENT:

DEPTH := 2

ifeq ($(MAKELEVEL), $(DEPTH))

negaalpha: $(DIR)
	cp $(DIR)/value $(RESULT)

else

ifeq ($(MAKELEVEL), 0)
RESULT := $(shell mktemp)
$(shell echo -99999 -99999 99999 >$(RESULT))
endif

tempfile := $(shell mktemp)
$(shell awk '{print -99999,-$$3,-$$2}' $(RESULT) >$(tempfile))
subdirs := $(wildcard $(DIR)/????)

.PHONY: negaalpha $(subdirs)

negaalpha: $(subdirs)
	rm $(tempfile)
ifeq ($(MAKELEVEL), 0)
	awk '{print $$4}' $(RESULT)
	rm $(RESULT)
endif

$(subdirs):
	-$(MAKE) -f ai/negaalpha.mk DIR=$@ RESULT=$(tempfile)
	awk '{v=-x;x=$$1} END{print v<$$1?$$1:v, v<$$2?$$2:v, $$3, v<$$1?$$4:"$(@F)" >"$(RESULT)"; if ($$3<=v) {system("rm $(tempfile)"); exit 1} }' $(tempfile) $(RESULT)

endif
