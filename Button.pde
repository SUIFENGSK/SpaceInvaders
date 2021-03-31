class Button 
{
    float x, y;
    String text;
    float buttonWidth = 200, buttonHeight = 80;
    float R = 225, G = 225, B = 225;
    boolean action = false;
    boolean active = false;
    Button(float x, float y, String text) 
    {
        this.x = x;
        this.y = y;
        this.text = text;
    }
    void createButton()
    {
        pushMatrix();
        stroke(0);
        render();
        rectMode(CENTER);
        fill(R, G, B);
        //rect(x, y, buttonWidth, buttonHeight);
        textSize(30);
        textAlign(CENTER, CENTER);
        text(text, x, y);
        popMatrix();
        checkButton();
        buttonAction();
    }
    void render() 
    {
        if (mouseX > x - buttonWidth / 2 && mouseX < x + buttonWidth / 2 && mouseY > y - buttonHeight / 2 && mouseY < y + buttonHeight / 2) {
            R = 200;
            G = 100;
            B = 150;
        } else {
            R = 225;
            G = 225;
            B = 225;
        }
    }
    void checkButton() 
    {
        if (mouseX > x - buttonWidth / 2 && mouseX < x + buttonWidth / 2 && mouseY > y - buttonHeight / 2 && mouseY < y + buttonHeight / 2) {
           if (mousePressed && action == false)
            {
                action = true;
        } else
                action = false;
        }
    }
    void buttonAction() 
    {
        if (action) {
            //println("hello");
        }
    }
}
