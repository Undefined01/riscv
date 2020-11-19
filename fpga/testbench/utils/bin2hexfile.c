#include <stdio.h>

int main(int argc, char **argv) {
	FILE *bin = fopen(argv[1], "r");
	FILE *hex = fopen(argv[2], "w");

	int count = 0;
	while (!feof(bin)) {
		int word = 0;
		int res = fread(&word, sizeof(int), 1, bin);
		if (res == 0) break;
		fprintf(hex, "@%02x\t%08x\n", count, word);
		count++;
	}
}
