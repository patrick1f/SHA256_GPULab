#ifndef __OPENCL_VERSION__
#include <OpenCL/OpenCLKernel.hpp> // Hack to make syntax highlighting in Eclipse work
#endif

#define pwdlength 4 //password length

//type definition for input
typedef struct {
	char word[pwdlength];
} wordStruct;
//type definition for output
typedef struct {
	uint hash[8];
} outStruct;

/**
 * rotr
 * rotate of x by n position
 * @param x
 * @param n
 * @return
 */
uint rotr(uint x, uint n) {
	return (x >> n) | (x << (32 - n));
}

/**
 * shr
 * shift of x by n position
 * @param x
 * @param n
 * @return
 */
uint shr(uint x, uint n) {
	return x >> n;
}

/**
 * Ch
 * calculate (x AND y) XOR ((not x) AND z)
 * @param x
 * @param y
 * @param z
 * @return
 */
uint Ch(uint x, uint y, uint z) {
	return (x & y) ^ (~x & z);
}

/**
 * Maj
 * calculate (x AND y) XOR (x AND z) XOR (y AND z)
 * @param x
 * @param y
 * @param z
 * @return
 */
uint Maj(uint x, uint y, uint z) {
	return (x & y) ^ (x & z) ^ (y & z);
}

/**
 * bigSigma0
 * XOR rotate of x by 2 position with rotate of x by 13 position and rotate of x by 22 position
 * @param x
 * @return
 */
uint bigSigma0(uint x) {
	return rotr(x, 2) ^ rotr(x, 13) ^ rotr(x, 22);
}

/**
 * bigSgma1
 * XOR rotate of x by 6 position with rotate of x by 11 position and rotate of x by 25 position
 * @param x
 * @return
 */
uint bigSigma1(uint x) {
	return rotr(x, 6) ^ rotr(x, 11) ^ rotr(x, 25);
}

/**
 * smallSigma0
 * XOR rotate of x by 7 position with rotate of x by 18 position and shift of x by 3 position
 * @param x
 * @return
 */
uint smallSigma0(uint x) {
	return rotr(x, 7) ^ rotr(x, 18) ^ shr(x, 3);
}

/**
 * smallSigma1
 * XOR rotate of x by 17 position with rotate of x by 19 position and shift of x by 10 position
 * @param x
 * @return
 */
uint smallSigma1(uint x) {
	return rotr(x, 17) ^ rotr(x, 19) ^ shr(x, 10);
}

//magic number of K
__constant uint K[] = { 0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
		0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01,
		0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
		0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa,
		0x5cb0a9dc, 0x76f988da, 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
		0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138,
		0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
		0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624,
		0xf40e3585, 0x106aa070, 0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
		0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f,
		0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2 };

//Original hash value
__constant uint origH[] = { 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
		0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19 };

//////////////////////////////////////////////////////////////////////////////
// Kernel function
//////////////////////////////////////////////////////////////////////////////
__kernel void kernel1(__global const wordStruct* d_input,
		__global outStruct* d_output, __global const int* d_length) {
	size_t index = get_global_id(0);
	int length = d_length[index];
	char t[10] = "";
	int leftover, stop, i;
	int a, b, c, d, e, f, g, h, T1, T2;

	uint W[16], temp[8];
	
	//get the input to local variable
	for (i = 0; i < length; i++) {
		t[i] = d_input[index].word[i];
	}

	//initial the message block
	for (i = 0; i < 16; i++) {
		W[i] = 0x00000000;
	}

	stop = length / 4; //4 char per W   //put in the first multiple of 4 numbers char to the message block
	
	//Assign the message block 4 char at a time
	for (i = 0; i < stop; i++) {
		W[i] = ((uchar) t[i * 4]) << 24;
		W[i] |= ((uchar) t[i * 4 + 1]) << 16;
		W[i] |= ((uchar) t[i * 4 + 2]) << 8;
		W[i] |= ((uchar) t[i * 4 + 3]);
	}

	// take care the rest of char and padding the 1
	leftover = length % 4;
	if (leftover == 3) {
		W[i] = ((uchar) t[i * 4]) << 24;
		W[i] |= ((uchar) t[i * 4 + 1]) << 16;
		W[i] |= ((uchar) t[i * 4 + 2]) << 8;
		W[i] |= 0x80;
	} else if (leftover == 2) {
		W[i] = ((uchar) t[i * 4]) << 24;
		W[i] |= ((uchar) t[i * 4 + 1]) << 16;
		W[i] |= 0x8000;
	} else if (leftover == 1) {
		W[i] = ((uchar) t[i * 4]) << 24;
		W[i] |= 0x800000;
	} else //if(leftover ==0)
	{
		W[i] = 0x80000000;
	}

	//pad the message length in bits in the last 64 bit
	W[15] = (uint) length * 8;

	//Assign message block 16 to 64 based on the first 15
	for (i = 16; i < 64; i++) {
		W[i] = smallSigma1(W[i - 2]) + W[i - 7] + smallSigma0(W[i - 15])
				+ W[i - 16];
	}
	
	//copy the original hash value to temperate register
	for (i = 0; i < 8; i++) {
		temp[i] = origH[i];
	}

	a = temp[0];
	b = temp[1];
	c = temp[2];
	d = temp[3];
	e = temp[4];
	f = temp[5];
	g = temp[6];
	h = temp[7];
	
	//do the sha256 hashing
	for (i = 0; i < 64; i++) {
		T1 = h + bigSigma1(e) + Ch(e, f, g) + K[i] + W[i];
		T2 = bigSigma0(a) + Maj(a, b, c);
		h = g;
		g = f;
		f = e;
		e = d + T1;
		d = c;
		c = b;
		b = a;
		a = T1 + T2;
	}

	//compute the result of hash with original hash value
	temp[0] += a;
	temp[1] += b;
	temp[2] += c;
	temp[3] += d;
	temp[4] += e;
	temp[5] += f;
	temp[6] += g;
	temp[7] += h;
	
	//Assign the result to output
	for (i = 0; i < 8; i++) {
		d_output[index].hash[i] = temp[i];
	}

}
