SRC=src/rmpd_imager.cr
OUTPUT=rmpd_imager.elf

all: shards
	crystal build --release $(SRC) -o $(OUTPUT)

shards:
	shards install
