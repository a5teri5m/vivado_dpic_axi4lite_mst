#include <stdio.h>
#include <string.h>
#include "svdpi.h"


#define FILENAME "scenario.csv"

FILE *fp;

DPI_DLLESPEC
int open_scn(
    void
){
    fp = fopen(FILENAME, "r");
    if(fp == NULL){
        printf("ERROR: cannot open file: %s\n", FILENAME);
        return 1;
    }
    return 0;    
}


DPI_DLLESPEC
int close_scn(
    void
){
    fclose(fp);
    return 0;    
}


DPI_DLLESPEC
int read_scn(
    int * const delay,
    int * const mode,
    int * const addr,
    int * const data
){
    char readline[32];
    char *find;
    char c_mode;

    if (fgets(readline, sizeof(readline), fp) == NULL){
        return 3;    
    }
    if ((find = strchr(readline,'\n')) != NULL){
        *find = '\0';    
    }
    if (sscanf(readline, " %d , %c , %x , %x ", delay, &c_mode, addr, data) == EOF){
        return 1;    
    }
    if (c_mode == 'W'){
        *mode = 1;    
    }else if(c_mode == 'R'){
        *mode = 0;    
    }else{
        return 2;    
    }
    return 0;    
}


