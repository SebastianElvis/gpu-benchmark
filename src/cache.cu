/* *
 * Copyright 1993-2012 NVIDIA Corporation.  All rights reserved.
 *
 * Please refer to the NVIDIA end user license agreement (EULA) associated
 * with this source code for terms and conditions that govern your use of
 * this software. Any use, reproduction, disclosure, or distribution of
 * this software and related documentation outside the terms of the EULA
 * is strictly prohibited.
 */
#include <stdio.h>
#include <stdlib.h>

#include <curand.h>
#include <curand_kernel.h>

#define SIZE (2048*1024/sizeof(int))

__device__ int *nonce;

// called by host, executed by GPU
__global__ void init() {
	nonce = (int *)malloc(SIZE*sizeof(int));
}

__global__ void setVals() {
	curandState_t state;

	/* we have to initialize the state */
	curand_init(0, /* the seed controls the sequence of random values that are produced */
			  0, /* the sequence number is only important with multiple cores */
			  0, /* the offset is how much extra we advance in the sequence for each call, can be 0 */
			  &state);
	for(int i=0;i<SIZE;i++){
		int r = curand(&state) % SIZE;
		//printf("%d ", r);
		*(nonce+r) = i;
	}
}

__global__ void getVals() {
	int j;
	for(int i=0;i<SIZE;i++){
		j = *(nonce+i);
		//printf("%d ", j);
	}
}

int main(void) {

	//printf("%d\n", sizeof(int));
	init<<<1, 1>>>();
	getVals<<<1, 1>>>();
	setVals<<<1, 1>>>();

	return 0;
}
