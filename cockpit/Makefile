SHELL=/bin/bash
PYTHON=python3

PYTHON_ENV=env

.PHONY: clean server

# environment #################################################################
$(PYTHON_ENV)/.created: REQUIREMENTS.txt
	rm -rf $(PYTHON_ENV) && \
	$(PYTHON) -m venv $(PYTHON_ENV) && \
	. $(PYTHON_ENV)/bin/activate && \
	pip install pip --upgrade && \
	pip install -r ./REQUIREMENTS.txt && \
	date > $(PYTHON_ENV)/.created

env: $(PYTHON_ENV)/.created

# environment helper ##########################################################
clean:
	rm -rf $(PYTHON_ENV)

# server ######################################################################
server: env
	. $(PYTHON_ENV)/bin/activate && \
	./server.py --host=localhost --port=9000 $(args)
