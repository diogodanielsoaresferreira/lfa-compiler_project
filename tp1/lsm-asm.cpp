#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <fstream>
#include "lsm-parser.h"
#include "lsm-lexer.h"
#include "lsm-data.h"


void store(uint32_t x, unsigned char msg[4]){
	char *ptr = (char*)&x;
	for(int i=3;i>=0;--i, ++ptr)
		msg[i] = *ptr;
}

void store(uint16_t x, unsigned char msg[2]){
	char *ptr = (char*)&x;
	for(int i=1;i>=0;--i, ++ptr)
		msg[i] = *ptr;
}

static const char* options =
    "OPTIONS:\n"
    "=======\n"
    " -h            this help\n"
    " -o file-path  output file (default: stdout)\n"
    " -s            syntax only\n"
    " -d            debug mode\n";


int yyparse(LSMData*);

int main(int argc, char *argv[])
{
    /* instantiate main data structure and init it with default values */
    LSMData lsm_data;
    FILE* ofp = NULL;

    if (yylex_init(&lsm_data.scanner))
    {
        fprintf(stderr, "Fail initing scanner\n");
        return(EXIT_FAILURE);
    }

    lsm_data.lbl_table = new LabelTable;

    lsm_data.syntax_only = false;
    lsm_data.error_cnt = 0;
    lsm_data.bss_size = 0;
    lsm_data.text_size = 0;
    lsm_data.first_time = true;
    lsm_data.debug_mode = false;

    char* opname = NULL;

    /* process command line arguments */
    int op = -1;

    while ((op = getopt(argc, argv, "ho:sd")) != -1)
    {
        switch (op)
        {
            case 'h':
                printf("%s [OPTIONS] lsm-file\n%s\n", argv[0], options);
                return 0;

            case 'o':
                opname=optarg;
                break;

            case 's':
                lsm_data.syntax_only = true;
                break;

            case 'd':
                lsm_data.debug_mode = true;
                break;

            default:
                fprintf(stderr, "Bad option\n");
                printf("%s [OPTIONS] input-file\n%s\n", argv[0], options);
                return EXIT_FAILURE;
        }
    }



    /* check if mandatory argument is present */
    if (argc - optind != 1)
    {
        fprintf(stderr, "Mandatory argument is not present\n");
        return EXIT_FAILURE;
    }

    /* set up input stream */

	fstream fin(argv[optind], fstream::in);
	char c = '9';
	while(true){
		if(fin.peek()==-1){
			if(c!='\n'){
				FILE* f = fopen(argv[optind], "a");
				fprintf(f,"\n");
                printf("WARNING: No newline ate the end of the file. Newline inserted.\n");
				fclose(f);
			}
			break;
		}
		c = fin.get();
	}

    FILE* ifp = fopen(argv[optind], "r");
    if (ifp == NULL)
    {
        fprintf(stderr, "Fail opening input file %s\n", argv[optind]);
        return EXIT_FAILURE;
    }

    yyset_in(ifp, lsm_data.scanner);

    
    /* call the parser first time*/
    yyparse(&lsm_data);

    /* call the parser second time time*/
    lsm_data.first_time = false;
    lsm_data.text_size = 0;
    if (yylex_init(&lsm_data.scanner))
    {
        fprintf(stderr, "Fail initing scanner\n");
        return(EXIT_FAILURE);
    }

    ifp = fopen(argv[optind], "r");

    if (ifp == NULL)
    {
        fprintf(stderr, "Fail opening input file %s\n", argv[optind]);
        return EXIT_FAILURE;
    }

    yyset_in(ifp, lsm_data.scanner);
    yyparse(&lsm_data);

    if(!lsm_data.syntax_only){

        if (opname==NULL)
        {
            char* p = argv[optind];
            char* q;
            int n = strlen(p);
            if ((q = strrchr(p, '.')) != NULL)
            {
                n = q - p;
            }
            char ofname[n+1];
            strncpy(ofname, p, n);
            strcpy(ofname+n, ".bsm");
            if ((ofp = fopen(ofname, "wb")) == NULL)
            {
                fprintf(stderr, "Fail opening output file %s\n", ofname);
                return EXIT_FAILURE;
            }
        }
        else if ((ofp = fopen(opname, "wb")) == NULL)
        {
            fprintf(stderr, "Fail opening output file %s\n", optarg);
            return EXIT_FAILURE;
        }

    	int totalSize;
    	int bufferCount = 0;
    	totalSize = lsm_data.bss_size + lsm_data.text.size() + lsm_data.data.size() + 14;
    	unsigned char buffer[totalSize];
    	uint32_t magic = 0xdebadada;
    	store(magic,&buffer[bufferCount]);
    	bufferCount += 4;
    	uint16_t major_version = 43343;
    	uint16_t minor_version = 2016;
    	store(major_version,&buffer[bufferCount]);
    	bufferCount+=2;
    	store(minor_version,&buffer[bufferCount]);
    	bufferCount+=2;

    	store((uint16_t)(lsm_data.bss_size),&buffer[bufferCount]);
    	bufferCount += 2;

    	store((uint16_t)(lsm_data.data.size()/4),&buffer[bufferCount]);
    	bufferCount += 2;


    	for(int8_t i: lsm_data.data){
    		buffer[bufferCount] = (char)i;
    		bufferCount++;
    	}

        store(lsm_data.text_size,&buffer[bufferCount]);
        bufferCount+=2;

    	for(int8_t i: lsm_data.text){
    		buffer[bufferCount] = (char)i;
    		bufferCount++;
    	}

    	fwrite(buffer,bufferCount,1,ofp);
        fclose(ofp);
    }
    else{
        printf("\n%d errors",lsm_data.error_cnt);
        printf("\nNo file generated.\n");
    }


    /* clean up and quit */
	fclose(ifp);

	yylex_destroy(lsm_data.scanner);
    delete lsm_data.lbl_table;
    return 0;
}
