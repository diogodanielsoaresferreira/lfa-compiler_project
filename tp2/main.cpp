/*
	LFA 2016 - Grupo 3
	Projeto 2
	David Almeida, Diogo Ferreira, Francisco Cunha, José Castanheira
	Main
*/

#include <getopt.h>
#include <stdio.h>
#include <stdint.h>
#include <string>
#include "ast.h"
#include "symtable.h"
#include "parser.h"
#include "lexer.h"
#include "main-data.h"


const char* options =
    "OPTIONS:\n"
    "=======\n"
    " -h            this help\n"
	" -o            output file (default: stdout)\n"
    " -ofile-path   output file (default: stdout)\n"
    " -s            syntax only (default)\n"
    " -t            show AST tree\n"
    " -g            generate LSM code\n"
	"\n";


/*

Instructions:
To generate code, send as an argument -g. This will generate code to the command line.

If you want to generate code for a file, send as an argument -o. This will create a file with the same name as the input file,
but with the extension ".s".

If you want specify the file name, send as an argument the filename attached with the "-o".

Example:
Output file test.s
./s16 input_file -g -otest.s


*/

int main(int argc, char *argv[])
{
    /* instantiate main data structure and init it with default values */
    MainData main_data;

    if (yylex_init(&main_data.scaninfo))
    {
        fprintf(stderr, "Fail initing scanner\n");
        return(EXIT_FAILURE);
    }

    main_data.ast = NULL;
    main_data.no_of_errors = 0;

	FILE* ofp = stdout;
	bool show = false;
	bool lsm = false;
	char* filename = NULL;
    /* process command line arguments */
    int op = -1;



	bool outputFileUndefined = false;
    while ((op = getopt(argc, argv, "ho::stg")) != -1)
    {
        switch (op)
        {
            case 'h':
                printf("%s [OPTIONS] path-to-image\n%s\n", argv[0], options);
                return 0;

            case 'o':

                if ((ofp = fopen((filename = optarg), "w")) == NULL)
                {
					outputFileUndefined = true;

                }
                break;

            case 's':
                break;

            case 'g':
				lsm = true;
                break;

            case 't':
				show = true;
                break;

            default:
                fprintf(stderr, "Bad option\n");
                printf("%s [OPTIONS] input-file\n%s\n", argv[0], options);
                return EXIT_FAILURE;
        }
    }

	if(outputFileUndefined){
		std::string tmp = std::string(argv[optind]);
		std::size_t pos = tmp.find(std::string("/"));
		if(pos != std::string::npos){
			tmp = tmp.substr(pos+1);
		}

		tmp.resize(tmp.size()-2);
		ofp = fopen(tmp.c_str(), "w");
	}

    if (argc - optind != 1)
    {
        fprintf(stderr, "Mandatory argument is not present\n");
        return EXIT_FAILURE;
    }

    /* set up input stream */
    FILE* ifp = fopen(argv[optind], "r");
    if (ifp == NULL)
    {
        fprintf(stderr, "Fail opening input file %s\n", argv[optind]);
        return EXIT_FAILURE;
    }

    yyset_in(ifp, main_data.scaninfo);

    /* call the parser */
    if (yyparse(&main_data) == 0)
    {
		if (show) main_data.ast->show(0);
		if (lsm) main_data.ast->generateLSM(ofp);
		printf("\n");
		fclose(ofp);
    }
	else{
		fclose(ofp);
		remove(filename);
	}


    yylex_destroy(main_data.scaninfo);
    delete main_data.symtable;
    delete main_data.ast;
    return 0;
}
