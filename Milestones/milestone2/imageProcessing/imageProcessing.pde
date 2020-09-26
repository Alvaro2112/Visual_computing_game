import java.util.Collections;

PImage img;
HoughTransform houghTool;
Thresholding thresholdTool;
BlobDetection blobs;
QuadGraph corners;

boolean done;

final int NUMBER_LINES_HOUGH= 6;
final boolean VERBOSE_QUAD = false;
final int RADIUS_CIRCLE_CORNERS = 15;

final int MAX_COLOR = 255;
final int MIN_COLOR = 0;

void settings() {
  size(800*3, 600);
}

void setup() {
  /* IMAGE PROCESSING TOOLS */
  houghTool = new HoughTransform();
  thresholdTool = new Thresholding();
  corners = new QuadGraph();
  blobs = new BlobDetection();

  /* LOADING IMAGE */
  img= loadImage("board4.jpg");
  done = false;
}

void draw() {
  if (!done) {
    PImage quads = thresholdTool.thresholdHue(img, 100, 138, 100, MAX_COLOR, MIN_COLOR, 200);
    quads = gaussianBlur(quads);
    quads = gaussianBlur(quads);
    quads = thresholdTool.threshold(quads, 100);
    
    quads = blobs.findConnectedComponents(quads, false);
    quads = scharrEdgeDetection(quads);

    List<PVector> corner_list = corners.findBestQuad(houghTool.hough(quads, NUMBER_LINES_HOUGH), img.width, img.height, (img.width * img.height), 0, VERBOSE_QUAD);

    image(img, 0, 0);
    houghTool.plotTheLines(img, houghTool.hough(quads, NUMBER_LINES_HOUGH));

    for (PVector angle : corner_list) {
      fill(MIN_COLOR);
      circle(angle.x, angle.y, RADIUS_CIRCLE_CORNERS);
    }
    
    PImage edges = thresholdTool.thresholdHue(img,100,150,70,MAX_COLOR,MIN_COLOR,200);
    edges = gaussianBlur(edges);
    edges = scharrEdgeDetection(edges);
    edges = gaussianBlur(edges);
    edges = thresholdTool.threshold(quads, 100);
    
    image(edges, img.width, 0);
    
    PImage blobDetect = thresholdTool.thresholdHueWithOriginalColor(img, 100, 138, 100, MAX_COLOR, MIN_COLOR, 200);
    blobDetect = thresholdTool.thresholdHue(blobDetect, 100, 150, 70, MAX_COLOR, MIN_COLOR, 200);
    blobDetect = gaussianBlur(blobDetect);
    blobDetect = gaussianBlur(blobDetect);
    blobDetect = thresholdTool.threshold(blobDetect, 100);
    blobDetect = blobs.findConnectedComponents(blobDetect, false);
    edges = gaussianBlur(edges);
    
    image(blobDetect, img.width*2, 0);
    
    done = true;
  }
 

}

/* IMAGE COMPARISON */
boolean imagesEqual(PImage img1, PImage img2) {
  if (img1.width != img2.width || img1.height != img2.height) {
    return false;
  }
  for (int i = 0; i < img1.width*img1.height; i++) {
    if (red(img1.pixels[i]) != red(img2.pixels[i])) {
      return false;
    }
  }
  //assuming that all the three channels have the same value
  return true;
}

/* IMAGE PROCESSING TOOLS */
float brightnessOfIndexed(PImage img, int x, int y) {
  return brightness(img.pixels[x + y*img.width]);
}

PImage gaussianBlur(PImage img) {
  float[][] kernel = { { 9, 12, 9 }, { 12, 15, 12 }, 
    { 9, 12, 9 }};
  float normFactor = 99.f;
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);

  int N = 3;
  for (int i = 0; i < img.width * img.height; i++) {
    float sum = 0;
    int xi = i % img.width - N/2;
    int yi = i/img.width - N/2;
    if (xi >= 0 && yi >= 0 && xi + N <= img.width && yi + N <= img.height) {
      for (int x = xi; x < xi + N; ++x) {
        for (int y = yi; y < yi + N; ++y) {

          sum += kernel[x - xi][y - yi] * brightnessOfIndexed(img, x, y);
        }
      }
      sum /= normFactor;
      result.pixels[i] = color(sum);
    } else {
      result.pixels[i] = color(MIN_COLOR);
    }
  }

  return result;
}


PImage scharrEdgeDetection(PImage img) {
  float[][] vKernel = {
    { 3, 0, -3 }, 
    { 10, 0, -10 }, 
    { 3, 0, -3 }};
  float[][] hKernel = {
    { 3, 10, 3}, 
    { 0, 0, 0}, 
    { -3, -10, -3 } };
  PImage result = createImage(img.width, img.height, ALPHA);
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = color(0);
  }
  float max=0;
  float[] buffer = new float[img.width * img.height];

  int N = 3;
  for (int i = 0; i < img.width * img.height; i++) {
    float sum_h = 0;
    float sum_v = 0;
    float sum = 0;
    int xi = i % img.width - N/2;
    int yi = i/img.width - N/2;
    if (xi >= 0 && yi >= 0 && xi + N <= img.width && yi + N <= img.height) {
      for (int x = xi; x < xi + N; ++x) {
        for (int y = yi; y < yi + N; ++y) {

          sum_h += hKernel[x - xi][y - yi] * brightnessOfIndexed(img, x, y);
          sum_v += vKernel[x - xi][y - yi] * brightnessOfIndexed(img, x, y);
        }
      }
      sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
      buffer[i] = sum;
      if (sum > max) {
        max = sum;
      }
    }
  }

  for (int y = 1; y < img.height - 1; y++) { // Skip top and bottom edges 
    for (int x = 1; x < img.width - 1; x++) { // Skip left and right
      int val=(int) ((buffer[y * img.width + x] / max)*MAX_COLOR);
      result.pixels[y * img.width + x]=color(val);
    }
  }
  return result;
}
