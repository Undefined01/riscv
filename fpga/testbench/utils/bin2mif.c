#include <stdio.h>

int main(int argc, char **argv) {
	FILE *bin = fopen(argv[1], "rb");
	FILE *mif = fopen(argv[2], "wb");

	fputs(
		"WIDTH=32;\n"
		"DEPTH=4096;\n"
		"ADDRESS_RADIX=HEX;\n"
		"DATA_RADIX=HEX;\n"
		"CONTENT\n"
		"BEGIN\n",
		mif
	);
	int count = 0;
	while (!feof(bin)) {
		int word = 0;
		int res = fread(&word, sizeof(int), 1, bin);
		if (res == 0) break;
		fprintf(mif, "%02x:\t%08x;\n", count, word);
		count++;
	}
	fputs("END;\n", mif);
}
