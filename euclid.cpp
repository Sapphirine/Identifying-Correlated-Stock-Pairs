#include "readFile.h"
#include <stdlib.h>
#include <sstream>
#include <math.h>
#include <string.h>
#include <algorithm>
#include <iomanip>

// Iterative version of quick-sort.
// Note that B is to be sorted in increasing
// order of A.
void quicksort(double *A, int *B, int N) {

  int *beg = (int*)malloc(N*sizeof(int));
  int *end = (int*)malloc(N*sizeof(int));

  double pivot_A;
  int pivot_B;
  int i=0, L, R, swap;

  beg[0]=0; end[0]=N;
  while (i>=0) {
    L=beg[i]; R=end[i]-1;

    if (L<R) {
      pivot_A=A[L];
      pivot_B=B[L];
      
      while (L<R) {
        while (A[R]>=pivot_A && L<R) R--;
        if (L<R) {
          A[L]=A[R];
          B[L]=B[R];
          L++;
        }
        while (A[L]<=pivot_A && L<R) L++;
        if (L<R) {
          A[R]=A[L];
          B[R]=B[L];
          R--;
        }
      }
      
      A[L]=pivot_A;
      B[L]=pivot_B;

      beg[i+1]=L+1;
      end[i+1]=end[i];
      end[i++]=L;
      
      if (end[i]-beg[i]>end[i-1]-beg[i-1]) {
        swap=beg[i];
        beg[i]=beg[i-1];
        beg[i-1]=swap;
        swap=end[i];
        end[i]=end[i-1];
        end[i-1]=swap;
      }
    } else {
      i--;
    }
  }
}

/* overloaded version that just
	sorts a single integer-valued vector. */
void quicksort(int *A, int N) {

  int *beg = (int*)malloc(N*sizeof(int));
  int *end = (int*)malloc(N*sizeof(int));

  int pivot_A;
  int i=0, L, R, swap;

  beg[0]=0; end[0]=N;
  while (i>=0) {
    L=beg[i]; R=end[i]-1;

    if (L<R) {
      pivot_A=A[L];
      
      while (L<R) {
        while (A[R]>=pivot_A && L<R) R--;
        if (L<R) {
          A[L]=A[R];
          L++;
        }
        while (A[L]<=pivot_A && L<R) L++;
        if (L<R) {
          A[R]=A[L];
          R--;
        }
      }
      
      A[L]=pivot_A;

      beg[i+1]=L+1;
      end[i+1]=end[i];
      end[i++]=L;
      
      if (end[i]-beg[i]>end[i-1]-beg[i-1]) {
        swap=beg[i];
        beg[i]=beg[i-1];
        beg[i-1]=swap;
        swap=end[i];
        end[i]=end[i-1];
        end[i-1]=swap;
      }
    } else {
      i--;
    }
  }
}

//  This function converts strings into integers.
int asInt(string source){
	stringstream intermediate(source);
	int target;
	intermediate >> target;
	return(target);
}

// 	Overloaded version to work on vectors.
vector <int> asInt(vector <string> source){
	vector <int> target(0);
	for(int i = 0;i<source.size();i++){
		target.push_back(asInt(source[i]));
	}
	return(target);
}

//  This function converts strings into doubles.
double asDouble(string source){
  stringstream intermediate(source);
  double target;
  intermediate >> target;
  return(target);
}

//  Overloaded version to work on vectors.
vector <double> asDouble(vector <string> source){
  vector <double> target(0);
  for(int i = 0;i<source.size();i++){
    target.push_back(asDouble(source[i]));
  }
  return(target);
}


double distxy(vector <double> x1, vector <double> x2){
	int i;
	double dist12 = 0;
	for(i=0;i<x1.size();i++){
		dist12 += (x1[i]-x2[i])*(x1[i]-x2[i]);
	}
	dist12 = sqrt(dist12);
	return(dist12);
}

/* inputs:
	x1 -- d-dimensional vector of traits for one obs.
	x2 -- N-dimensional vector of d-dimensional vector of candidate neighbors.
	y -- N-dimensional vector of classes for candidate fits.
   output:
   	integer-valued choice.	*/
int classification(vector <double> x1, vector < vector <double> > x2, vector <int> y){
	int i;

	// minimum 5 distances will be saved
	// and sorted.
  	double *minDist = (double*)malloc(5*sizeof(double));
  	int *choices = (int*)malloc(5*sizeof(int));	

	for(i=0;i<5;i++){
		minDist[i] = distxy(x1,x2[i]);
    choices[i] = y[i];
	}
	quicksort(minDist,choices,5);

	for(i=5;i<x2.size();i++){
		double d = distxy(x1,x2[i]);
		if(d<minDist[4]){
			minDist[4] = d;
			choices[4] = y[i];
			quicksort(minDist,choices,5);
		}
	}
	// sort choices and select the median.
	quicksort(choices,5);
	return(choices[2]);
}

vector <int> classifyData(vector < vector < double > > x1, vector < vector < double > > x2, vector <int> y){
	vector <int> classes(0);
	int i;
	for(i=0;i<x1.size();i++){
    if(i % 100==0){
      printf("Iteration %d\n",i);
    }
		classes.push_back(classification(x1[i],x2,y));
	}
	return(classes);
}

int main() {
	
	vector < string > xStringTrain = readFile("xns.pct5.2010.txt");
  vector < string > xStringTest = readFile("xns.pct5.2011.txt");

	vector < int > yTrain = asInt(readFile("y01.pct5.2010.txt"));
  vector < int > yTest = asInt(readFile("y01.pct5.2011.txt"));

	vector < vector < double > > xTest(0);
	vector < vector < double > > xTrain(0);

	int i;
  for(i=0;i<xStringTrain.size();i++){
    xTrain.push_back(asDouble(parseLine(xStringTrain[i],"\t")));
  }
  for(i=0;i<xStringTest.size();i++){
    xTest.push_back(asDouble(parseLine(xStringTest[i],"\t")));
  }

	vector <int> yEst = classifyData(xTest, xTrain, yTrain);

  int correct1 = 0;
  int correct0 = 0;
  int wrong1 = 0;
  int wrong0 = 0;

  for(i=0;i<yEst.size();i++){
    if(yEst[i]==1 & yTest[i]==1){
      correct1++;
    } else if(yEst[i]==0 & yTest[i]==0){
      correct0++;
    } else if(yEst[i]==1 & yTest[i]==0){
      wrong1++;
    } else {
      wrong0++;
    }
  }

  cout << "\tclass\n";
  cout << "\t0\t1\n";
  cout << "0\t" << correct0 << '\t' << wrong1 << endl;
  cout << "1\t" << wrong0 << '\t' << correct1 << endl;
	
	return(0);
}
