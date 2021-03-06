/* Copyright (c) 2017, 2018 Tony Fischetti
 *
 * MIT License, http://www.opensource.org/licenses/mit-license.php
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a 
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense, 
 * and/or sell copies of the Software, and to permit persons to whom the 
 * Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 * DEALINGS IN THE SOFTWARE.
 * 
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <libgen.h>
#include <string.h>
#include <limits.h>

const int BLOCK_SIZE = 500;


const char *header_text = 
    "\nonetime v0.5 -- one-time pad encryption on files (byte by byte)\n";

const char *usage_text =
    "usage: onetime [-heds | -o output] input-file <one-time-pad>\n";



void add(size_t howmany, int *one, int *two, int *ciphertext){
    for(int i = 0; i < howmany; i++){
        *(ciphertext+i) = *(one+i) + *(two+i);
    }
}

void sub(size_t howmany, int *one, int *two, int *ciphertext){
    for(int i = 0; i < howmany; i++){
        *(ciphertext+i) = *(one+i) - *(two+i);
    }
}


int main(int argc, char** argv){
    int             CURRENT_INS[BLOCK_SIZE];
    int             CURRENT_ONES[BLOCK_SIZE];
    unsigned long   IN_LEN;
    unsigned long   ONE_LEN;
    int             CURRENT_CIPHERS[BLOCK_SIZE];
    void            (*PROC_PNT)(size_t, int*, int*, int*);
    int             ONE_BIGGER = 0;
    char*           IN_FN;
    char*           ONE_FN;
    char*           OUT_FN = "this gets overwriten";
    int             OUT_SPECIFIED = 0;
    int             DECRYPT_SPECIFIED = 0;
    int             ENCRYPT_SPECIFIED = 0;
    int             SHOW_ONE_TIME_SPECIFIED = 0;

    // default is to encrypt
    PROC_PNT = &add;

    // for option parsing
    int c;

    static struct option long_options[] =
    {
        {"encrypt", no_argument, 0, 'e'},
        {"decrypt", no_argument, 0, 'd'},
        {"show-onetimefile", no_argument, 0, 's'},
        {"output",  required_argument, 0, 'o'},
        {0, 0, 0, 0}
    };
    
    int long_index = 0;
    while ((c = getopt_long(argc, argv,"hdeso:", 
                   long_options, &long_index )) != -1) {
        switch (c) {
             case 'e':
                 if(DECRYPT_SPECIFIED){
                     fprintf(stderr, "Must be either encryption or decryption\n");
                     exit(EXIT_FAILURE);
                 }
                 ENCRYPT_SPECIFIED = 1;
                 PROC_PNT = &add;
                 break;
             case 'd':
                 if(ENCRYPT_SPECIFIED){
                     fprintf(stderr, "Must be either encryption or decryption\n");
                     exit(EXIT_FAILURE);
                 }
                 DECRYPT_SPECIFIED = 1;
                 PROC_PNT = &sub;
                 OUT_FN = "decryptedfile";
                 break;
             case 's':
                 SHOW_ONE_TIME_SPECIFIED = 1;
                 break;
             case 'o':
                 OUT_FN = optarg;
                 OUT_SPECIFIED = 1;
                 break;
             case 'h':
                printf("%s", header_text);
                printf("%s\n", usage_text);
                exit(EXIT_FAILURE);
            case '?':
                printf("%s\n", usage_text);
                exit(EXIT_FAILURE);
             default:
                 fprintf(stderr, usage_text);
                 exit(EXIT_FAILURE);
        }
    }

    if(optind+1 ==argc){
        IN_FN = argv[optind++];
        ONE_FN = getpass("Enter one-time pad file: ");
        if(strlen(ONE_FN) == 0){
            fprintf(stderr, "No one-time pad file specified\n");
            exit(EXIT_FAILURE);
        }
        if(strlen(ONE_FN) > 127 || strlen(ONE_FN) >= PASS_MAX){
            fprintf(stderr, "one-time pad filename too long: possibility of truncation\n");
            exit(EXIT_FAILURE);
        }
    }
    else if(optind+2 == argc){
        IN_FN = argv[optind++];
        ONE_FN = argv[optind++];
    }
    else{
        fprintf(stderr, "missing files\n");
        fprintf(stderr, usage_text);
        exit(EXIT_FAILURE);
    }

    
    if(SHOW_ONE_TIME_SPECIFIED){
        printf("One-time pad file is: %s\n  Continue? (y/n) ", ONE_FN);
        char response[2];
        fgets(response, 2, stdin);
        if(strcmp(response, "y")!=0 && strcmp(response, "Y")){
            fprintf(stderr, "quitting\n");
            exit(EXIT_FAILURE);
        }
    }

    if(DECRYPT_SPECIFIED==0 && ENCRYPT_SPECIFIED==0)
        ENCRYPT_SPECIFIED = 1;

    // if output file isn't specified
    // let's use good defaults
    if(OUT_SPECIFIED==0){
        // default filenames for encryption...
        // appends ".pad" to the filename
        if(ENCRYPT_SPECIFIED){
            char* base = basename(IN_FN);
            int length = strlen(base);
            char tmp[length+5];
            memset(tmp, '\0', length*sizeof(char)+1);
            strncpy(tmp, base, length);
            strncat(tmp, ".pad", 5);
            tmp[length+5] = '\0';
            OUT_FN = (char*) malloc(strlen(tmp)*sizeof(char)+1);
            if(!OUT_FN){
                fprintf(stderr, "Fatal error: failed to allocate memory\n");
                exit(EXIT_FAILURE);
            }
            memset(OUT_FN, '\0', strlen(tmp)*sizeof(char)+1);
            strncpy(OUT_FN, tmp, length+5);
        }
        // for default decrypted filenames....
        // check if it ends with ".pad"
        // if so, remove it, if not, use
        // "decryptedfile"
        else{
            char* base = basename(IN_FN);
            int len = strlen(base);
            int start = len-4;
            const char* comp = ".pad";
            int j = 0;
            int num_matches = 0;
            for(int i=start; i < len; i++){
                if(base[i] == comp[j])
                    num_matches++;
                j++;
            }
            if(num_matches==4){
                char tmp[len-5];
                for(int k=0; k < len-4; k++){
                    tmp[k] = base[k];
                }
                // this caused heartache
                tmp[len-4] = '\0';
                OUT_FN = (char*) malloc(strlen(tmp)*sizeof(char)+1);
                if(!OUT_FN){
                    fprintf(stderr, "Fatal error: failed to allocate memory\n");
                    exit(EXIT_FAILURE);
                }
                memset(OUT_FN, '\0', strlen(tmp)*sizeof(char)+1);
                strncpy(OUT_FN, tmp, strlen(tmp));
            }
        }
    }

    // open files if checks pass
    FILE* IN_FH = fopen(IN_FN, "rb");
    if(IN_FH==NULL){
        fprintf(stderr, "error: couldn't open input file (does it exist?)\n");
        exit(1);
    }
    FILE* ONE_FH = fopen(ONE_FN, "rb");
    if(ONE_FH==NULL){
        fprintf(stderr, "error: couldn't open one-time pad file (does it exist?)\n");
        exit(1);
    }
    FILE* tmp = fopen(OUT_FN, "rb");
    if(tmp){
        fprintf(stderr, "error: output file already exists\n");
        exit(1);
    }
    FILE* OUT_FH = fopen(OUT_FN, "wb");
    if(OUT_FH==NULL){
        fprintf(stderr, "error: can't write to output file (is there a directory that doesn't exist?)\n");
        exit(1);
    }

    // getting size of input file
    fseek(IN_FH, 0L, SEEK_END);
    IN_LEN = ftell(IN_FH);
    fseek(IN_FH, 0, SEEK_SET);

    // getting size of one time pad
    fseek(ONE_FH, 0L, SEEK_END);
    ONE_LEN = ftell(ONE_FH);
    fseek(ONE_FH, 0, SEEK_SET);

    // one time pad needs to be bigger than block size
    if(ONE_LEN < BLOCK_SIZE){
        fprintf(stderr, "fatal error: one time pad is too small\n");
        int ret = unlink(OUT_FN);
        if(ret!=0)
            fprintf(stderr, "fatal: could not remove output file\n");
        exit(1);
    }

    // check if one time pad is smaller than input file
    if(IN_LEN > ONE_LEN){
        ONE_BIGGER = 1;
        printf("Warning: one time pad is smaller than input file. Will recycle\n");
    }


    // loop that does the (en|de)cryption
    for(int i=0; i < IN_LEN; i+=BLOCK_SIZE){
        int howmany = fread(CURRENT_INS, sizeof(char), BLOCK_SIZE, IN_FH);
        int howmanyone = fread(CURRENT_ONES, sizeof(char), BLOCK_SIZE, ONE_FH);
        if(ONE_BIGGER){
            if(howmanyone < howmany){
                int thediff = howmany-howmanyone;
                fseek(ONE_FH, 0, SEEK_SET);
                int howaboutnow = fread(&CURRENT_ONES[howmanyone], sizeof(char),
                                        thediff, ONE_FH);
                if((howaboutnow+howmanyone) < howmany){
                    fprintf(stderr, "fatal error: one time pad is too small\n");
                    int ret = unlink(OUT_FN);
                    if(ret!=0)
                        fprintf(stderr, "fatal: could not remove output file\n");
                    exit(1);
                }
            }
        }

        (*PROC_PNT)(howmany, CURRENT_INS, CURRENT_ONES, CURRENT_CIPHERS);

        fwrite(CURRENT_CIPHERS, sizeof(char), howmany, OUT_FH);
        if(howmany<BLOCK_SIZE)
            break;
    }

    // close the files
    fclose(IN_FH);
    fclose(ONE_FH);
    fclose(OUT_FH);

    return 0;
}
