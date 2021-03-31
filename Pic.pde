class Pic {
    PImage img;
    int k;
    Pic(String filename) 
    {
        img = loadImage(filename + ".png");
    }
    Pic(String filename, int temp) 
    {
        k = temp;
        img = loadImage(filename + k + ".png");
    }
    void display(float x, float y, float pWidth, float pHeight)
    {
        imageMode(CENTER);
        image(img, x, y, pWidth, pHeight); //<>//
    }
}
