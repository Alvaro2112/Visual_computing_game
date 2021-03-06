/********** A S S I G N E M E N T   1 0 **********/

final class HoughTransform {

  public HoughTransform(int a) {
  }

  public List<PVector> hough(PImage edgeImg, int nLines) {
    float discretizationStepsPhi= 0.06f; 
    float discretizationStepsR= 1.75f; 
    int minVotes=125;

    // dimensions of the accumulator
    int phiDim= (int) (Math.PI / discretizationStepsPhi+1);

    //The max radius is the image diagonal, but it can be also negative
    int rDim= (int) ((sqrt(edgeImg.width*edgeImg.width+edgeImg.height*edgeImg.height) * 2) / discretizationStepsR+1);

    // our accumulator
    int[] accumulator=new int[phiDim* rDim];

    // pre-compute the sin and cos values
    float[] tabSin = new float[phiDim];
    float[] tabCos = new float[phiDim];
    float ang = 0;
    float inverseR = 1.f / discretizationStepsR;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }


    // Fill the accumulator: on edge points (ie, white pixels of the edge
    // image), store all possible (r, phi) pairs describing lines going
    // through the point.
    for (int y = 0; y < edgeImg.height; y++) {
      for (int x = 0; x < edgeImg.width; x++) {
        // Are we on an edge?
        if (brightness(edgeImg.pixels[y * edgeImg.width+ x]) != 0) {

          // ...determine here all the lines (r, phi) passing through
          // pixel (x,y), convert (r,phi) to coordinates in the
          // accumulator, and increment accordingly the accumulator.
          // Be careful: r may be negative, so you may want to center onto
          // the accumulator: r += rDim / 2

          for (int i = 0; i < phiDim; i ++) {
            double r = x * tabCos[i] + y * tabSin[i];
            r += rDim / 2;
            accumulator[(int)(i*rDim+r)] += 1;
          }
        }
      }
    }

    ArrayList<Integer> bestCandidates = new ArrayList<Integer>();

    int region_dim = 10;

    for (int i = 0; i < accumulator.length; i++) {
      if (accumulator[i] > minVotes) {
        boolean is_best = true;
        for (int j = 0; j < 2 * region_dim; j++) {
          if ((j - region_dim + i >= 0) && (j - region_dim + i < accumulator.length) &&  (j - region_dim + i != 1)) {
            if (accumulator[j- region_dim + i] > accumulator[i]) {
              is_best = false;
              break;
            }
          }
        }
        if (is_best) {
          bestCandidates.add(i);
        }
      }
    }

    Collections.sort(bestCandidates, new HoughComparator(accumulator));


    PImage houghImg = createImage(rDim, phiDim, ALPHA);
    for (int i = 0; i < accumulator.length; i++) {
      houghImg.pixels[i] = color(min(255, accumulator[i]));
    }

    houghImg.resize(400, 400); 
    houghImg.updatePixels();

    ArrayList<PVector> lines = new ArrayList<PVector>();

    for (int idx= 0; idx < Math.min(bestCandidates.size(), nLines); idx++) {
      int i = bestCandidates.get(idx);
      int accPhi= (int) (i / (rDim));
      int accR= i- (accPhi) * (rDim);
      float r = (accR- (rDim) * 0.5f) * discretizationStepsR;
      float phi = accPhi* discretizationStepsPhi;
      lines.add(new PVector(r, phi));
    }

    return lines;
  }

  public void plotTheLines(PImage edgeImg, List<PVector> lines) {
    for (int idx = 0; idx< lines.size(); idx++) {
      PVector line = lines.get(idx);
      float r = line.x; 
      float phi = line.y;
      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)

      // compute the intersection of this line with the 4 borders of
      // the image
      int x0 = 0;
      int y0 = (int) (r / sin(phi));
      int x1 = (int) (r / cos(phi));
      int y1 = 0;
      int x2 = edgeImg.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = edgeImg.width;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));

      // Finally, plot the lines
      stroke(204, 102, 0);
      if (y0 > 0) {
        if (x1 > 0)
          line(x0, y0, x1, y1);
        else if (y2 > 0)
          line(x0, y0, x2, y2);
        else
          line(x0, y0, x3, y3);
      } else {
        if (x1 > 0) {
          if (y2 > 0)
            line(x1, y1, x2, y2);
          else
            line(x1, y1, x3, y3);
        } else
          line(x2, y2, x3, y3);
      }
    }
  }
}
