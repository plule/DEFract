extern vec3 position; // Position of the Eye
extern vec3 origin; // origin of the projection plane
extern vec3 planex;  // definition of the projection plane
extern vec3 planey;

float w = %f;     // Size of the window
float h = %f;
extern float maxIterations; // Max number of rendering step
extern float thresholdFactor;// Limit to estimate that we touch the object
float PI = 3.141592654;


int maxIt; // maxIterations converted to int
