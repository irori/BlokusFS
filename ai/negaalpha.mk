.SILENT:

DEPTH := 2
depth-1 := $(word $(DEPTH), 0 1 2 3 4 5 6 7 8 9)

ifeq ($(MAKELEVEL), $(depth-1))

negaalpha: $(DIR)
	awk 'BEGIN{getline < "$(RESULT)"; b=$$3; x=-99999} {v=-$$1;if(x<v){x=v;if(b<=x){exit 0}}} END{print x,x,b > "$(RESULT)"}' $(DIR)/*/value

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
ifeq ($(MAKELEVEL), 0)
	awk '{print $$4}' $(RESULT)
	rm $(RESULT)
endif

$(subdirs):
	awk '{print -99999,-$$3,-$$2}' $(RESULT) >$(tempfile)
	-$(MAKE) -f ai/negaalpha.mk DIR=$@ RESULT=$(tempfile) >/dev/null
	awk '{v=-x;x=$$1} END{print v<$$1?$$1:v, v<$$2?$$2:v, $$3, v<$$1?$$4:"$(@F)" >"$(RESULT)"; if ($$3<=v) {system("rm $(tempfile)"); exit 1} }' $(tempfile) $(RESULT)
ifeq ($(MAKELEVEL), 0)
	cat $(RESULT) 1>&2
endif

endif
