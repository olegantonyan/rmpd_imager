SRC=src/rmpd_imager.cr
OUTPUT=rmpd_imager.elf
INSTALL_PREFIX=$(HOME)/bin

all: shards
	crystal build --release $(SRC) -o $(OUTPUT)

shards:
	shards install

install:
	cp $(OUTPUT) $(INSTALL_PREFIX)/
