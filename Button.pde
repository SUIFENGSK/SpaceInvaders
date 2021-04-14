class Button 
{
    float x, y;
    String text;
    float buttonWidth = 200, buttonHeight = 80; //Set the size of the button
    float R = 225, G = 225, B = 225; //Set the color of the button
    boolean action = false, buttonBgmControl = true;
    float textSize;
    Button(float x, float y, String text, float textSize) 
    {
        this.x = x;
        this.y = y;
        this.text = text;
        this.textSize = textSize;
    }
    void createButton()
    {
        //Create and display button
        pushMatrix();
        stroke(0);
        render(); //Render button
        rectMode(CENTER);
        fill(R, G, B);
        //rect(x, y, buttonWidth, buttonHeight);
        textSize(textSize);
        textAlign(CENTER, CENTER);
        text(text, x, y);
        popMatrix();
        //Check whether the button is triggered
        checkButton();
    }
    void render() 
    {
        //If the mouse position coincides with the button position, re-render the button (change the color of the button)
        if (mouseX > x - buttonWidth / 2 && mouseX < x + buttonWidth / 2 && mouseY > y - buttonHeight / 2 && mouseY < y + buttonHeight / 2) {
            R = 138;
            G = 217;
            B = 78;
            if (buttonBgmControl) 
            {
                buttonBgm.play();
                buttonBgmControl = false;
            }
        } else {
            R = 225;
            G = 225;
            B = 225;
            buttonBgmControl = true;
        }
    }
    void checkButton() 
    {
        //Check whether the button is triggered. Return true if triggered
        if (mouseX > x - buttonWidth / 2 && mouseX < x + buttonWidth / 2 && mouseY > y - buttonHeight / 2 && mouseY < y + buttonHeight / 2) 
        {
            if (mousePressed && action == false)  action = true;
            else  action = false;
        }
    }
}
