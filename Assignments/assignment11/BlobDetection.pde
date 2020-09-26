import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;


class BlobDetection {
  PImage findConnectedComponents(PImage input, boolean onlyBiggest) {

    PImage img = input;
    
    // First pass: label the pixels and store labels' equivalences

    int [] labels= new int [img.width * img.height];
    List<TreeSet<Integer>> labelsEquivalences= new ArrayList<TreeSet<Integer>>();

    int currentLabel = 0;

    ArrayList<Integer> counter = new ArrayList<Integer>();

    for (int y_axis = 0; y_axis <  img.height; y_axis++) {//loop through image

      TreeSet<Integer> neighbours = new TreeSet<Integer>();

      for (int x_axis = 0; x_axis < img.width; x_axis++) {

        if (brightness(img.pixels[y_axis * img.width + x_axis]) == 255) { //check if white

          neighbours.clear();

          //Check that (y_axis) != 0 to not do 0 - 1
          if (boolean(y_axis)) {
            int pos = (y_axis - 1)*img.width+x_axis;
            if (labels[pos] != 0) {
              neighbours.add(labels[pos]);
            }
          }

          //Check that (x_axis) != 0 to not do 0 - 1
          if (boolean(x_axis)) {
            int pos = y_axis * img.width + x_axis-1;
            if (labels[pos] != 0) {
              neighbours.add(labels[pos]);
            }
          }
          
          int pos = x_axis + y_axis * img.width;
          
          if (neighbours.isEmpty()) {
            currentLabel += 1;
            TreeSet<Integer> convert = new TreeSet<Integer>();
            convert.add(currentLabel); //convert to set

            labelsEquivalences.add(convert); 
            counter.add(1);
            labels[pos] = currentLabel;
          } else {

            if (neighbours.size() >= 1) {
              for (int n : neighbours) {
                labelsEquivalences.get(n-1).addAll(neighbours);//add neighbours
              }
            }

            counter.set(neighbours.first() - 1, counter.get(neighbours.first() - 1) + 1);
            labels[pos] = neighbours.first();
          }
        }
      }
    }
    
    // Second pass: re-label the pixels by their equivalent class
    // if onlyBiggest==true, count the number of pixels for each label
    
    for (int i = 0; i < labelsEquivalences.size(); i++) { //loop through classes

      if (labelsEquivalences.get(i).size() >= 1) { //if at least one element in a class
      
        TreeSet<Integer> aux1 =new TreeSet<Integer>();

        for (Integer index : labelsEquivalences.get(i)) {
          
          if (labelsEquivalences.get(i) != labelsEquivalences.get(index-1)) { 
            aux1.addAll(labelsEquivalences.get(index-1));
            
          }
        }

        labelsEquivalences.get(i).addAll(aux1);
        for (Integer index : labelsEquivalences.get(i)) {
          labelsEquivalences.set(index-1, labelsEquivalences.get(i));
        }
      }
    }

    // Finally:
    // if onlyBiggest==false, output an image with each blob colored in one uniform color
    // if onlyBiggest==true, output an image with the biggest blob in white and others in black

    int[] class_size = new int[labelsEquivalences.size()];

    for (int i=0; i < labelsEquivalences.size(); i++) {
      for (Integer index : labelsEquivalences.get(i)) {
        class_size[i] += counter.get(index-1); //computes size of each class
      }
    }


    int[] colors = new int[class_size.length];

    if (!onlyBiggest) {
      for (TreeSet<Integer> equi : labelsEquivalences) {
        int random_color = color(random(255), random(255), random(255)); // get new random color for different blob
        for (Integer index : equi) {
          colors[index-1] = random_color;
        }
      }
    } else {

      int max = 0;

      for (int i=0; i < class_size.length; i++) {
        max = max < class_size[i] ? class_size[i] : max; //find max value
      }
      for (int i=0; i < class_size.length; i++) {
        colors[i] = (class_size[i] == max ? color(255) : color(0)); //remove all that dont have max value
      }
    }
    for (int i=0; i < img.width * img.height; i++) { //loop through pixels
      if (boolean(labels[i])) { // check that pixel belongs to a blob
        img.pixels[i] = colors[labels[i] - 1]; //assign colors
      }
    }
    return img;
  }
}
