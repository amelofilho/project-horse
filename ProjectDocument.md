# Black Rabbit Rhapsody #

## Summary ##

Turn-based autobattler 

## Project Resources

[Web-playable version of your game.](https://itch.io/)  
[Proposal: make your own copy of the linked doc.](https://docs.google.com/document/d/1jB2_lGxjSw8QCz2dgsFHjkJ77vtSrayT5uPSMNy5jAg/edit?usp=sharing)  

## Gameplay Explanation ##

In battle, there is a skill selection UI that can be broken down into columns with each representing one attack slot. Players can pick one of three available skills for an attack slot, or click on the button below (either portrait or defend button) to queue up an attack skill instead. Skills are then processed in order from fastest to slowest (based on speed number below the set of skills), left-to-right and pitted against the enemy's skills. 

Player skills and enemies skills then clash against each other, rolling for highest number to see who gets to attack. Players can do a QTE activated by clicking in order to gain more clash value. After clashing, whoever won the clash (winning enough times to break all the enemy skill's coins) gets to attack with the remaining coins on their skill. 

Once all skills are clashed or processed, the next turn begins. This goes on until one side is defeated.

**Strategy**
Pick big numbers to go up against enemy numbers. Defend when you feel like losing is inevitable.

**In this section, explain how the game should be played. Treat this as a manual within a game. Explaining the button mappings and the most optimal gameplay strategy is encouraged.**

**Add it here if you did work that should be factored into your grade but does not fit easily into the proscribed roles! Please include links to resources and descriptions of game-related material that does not fit into roles here.**

# External Code, Ideas, and Structure #

If your project contains code that: 1) your team did not write, and 2) does not fit cleanly into a role, please document it in this section. Please include the author of the code, where to find the code, and note which scripts, folders, or other files that comprise the external contribution. Additionally, include the license for the external code that permits you to use it. You do not need to include the license for code provided by the instruction team.

If you used tutorials or other intellectual guidance to create aspects of your project, include reference to that information as well.

Agentic Tools were used during the creation of an early draft of the UI code and for minor debugging.

# Team Member Contributions

This section be repeated once for each team member. Each team member should provide their name and GitHub user information.

The general structures is 
```
Team Member 1
  Main Role
    Documentation for main role.
  Sub-Role
    Documentation for Sub-Role
  Other contribtions
    Documentation for contributions to the project outside of the main and sub roles.

Team Member 2
  Main Role
    Documentation for main role.
  Sub-Role
    Documentation for Sub-Role
  Other contribtions
    Documentation for contributions to the project outside of the main and sub roles.
...
```
## Alexander Landess
  ### Game Logic
    asdf
  ### Gameplay Testing
    asdf
  ### Other Contributions
    asdf

## Kynan Lewis
  ### Level/World Designer
    asdf
  ### Game Feel
    asdf
  ### Other Contributions
    asdf

# Xiaofeng Lin
  ### Systems and Tools Engineer
    asdf
  ### Build/Release Management
    asdf
  ### Other Contributions
    asdf

# Danielle Chang
  ### Animation/Visuals
Moodboards
Came up with multiple moodboards on potential themes/directions we could take our game. As I was solely in charge of making most of the assests for the game, I wanted to have a clear direction in which I was gonna go that my team was also on board with. (example of one we didn't use below).
![moodboard_4](https://github.com/user-attachments/assets/d8a4a537-ede5-42b4-9c4d-20cdace67dd3)
And after a meeting, we decided to go with a modern story book/fairy tale vibe which we all thought was pretty cool.
    
Asset Creation
After agreeing on a creative direction during a meeting, I came up with mockups/initial sketches of what art style we could go for (we ended up not going for any of these), and to see if we wanted to do pixel art or regular art. Along with the main two characters I was also in charge of making and designing the mob sprites.
<img width="683" height="512" alt="IMG_5069" src="https://github.com/user-attachments/assets/12b153fa-7243-41d6-85c2-fde60566cc07" />
<img width="683" height="512" alt="IMG_5087" src="https://github.com/user-attachments/assets/f295c6d6-1147-4534-8e5f-965bffe9203e" />
<img width="683" height="512" alt="IMG_5088" src="https://github.com/user-attachments/assets/b5b53268-bacf-41e2-aaa3-b0eddcc262c6" />

I made multiple animations for the two characters, including idle, move, guard, hurt, and several attack animations for each (as we learned in class they should always being doing something even if it's just an idle animation). The two boss sprites also have multiple animations to keep NPC's moving at all times. 

Color Pallettes/Overall Mood
I thought that the colors should also play a role in game feel and after initial character pitches and design, I suggested the idea of doing a more muted/monochromatic color palleteand after some talking with Justin we decided to go ahead with that idea and add in signature colors for each character to kind of represent their fairy tale and make them a little more recognizable.
      
Start Screen
I wanted to make a starting screen for our game because user experience is key to me and I know every detail matters (especially first impressions), so continuing with the idea of story book I made a Start Screen with a story book vibe where it feels like the     .
    
Background and other Assests
I also gave consideration to the .
    
  ### Narrative Design
    Color Pallettes/Overall Mood

    Story/Theme
    
  ### Other Contributions
    asdf

# Adriano Melo Filho
  ### UI/Input
    asdf
  ### Audio
    asdf
  ### Other Contributions
    asdf

# Justin Pak
### Producer
Project Trello: https://trello.com/b/zCzT0oPH/project-horse-ecs-179 - Project planning and task tracking kanban board for helping
people know what they have to do, when they have to finish, and who has to work on it. I chose to use a Kanban board over a 
Gantt chart because I thought it would fit better with our team's dynamic and working process.
Also included were milestones implemented at the start of development. Other than being a part of the producer deliverables, project 
planning was discussed as a part of class during lectures regarding the project and tools you can use to help with the process.

GDScript Format Workflow - Made a GitHub workflow for automatically formatting all pushed gdscript files. This allows everyone to 
code in their own preferred style while ensuring that all final code aligns to one consistent style. This workflow is based on the 
portion of the course that covered Godot code style and best practices.

Assigning Tasks, Holding Meetings - Held regular team meeting to make sure everyone was on the same page and took minutes for each meeting.

<img src="DocImages/minutes.jpeg" width="400"/>

Producer Stuff - Tried to help be a force multiplier for the team. Helped act as a middleman between team members. Coordinated responsibilities and 
task. Keep everyone on the same page. Helped support any other team members who need assistance. Managed deadlines and scope. Made choices when things 
had to be delayed or scoped down. GitHub workflow.

### Visual Cohesion/Style Guide
Moodboard/Style Guide - I worked with Danielle to nail down what the core aesthetic of the game should be. She created the first set of moodboards and I created the second set to lock in on what the game's visuals would be like. Originally, the game was leaning more towards gothic or fantasy elements. 

<img src="DocImages/compiled-moodboard-2.jpeg" width="400"/>

Later, we decided to go for an "urban fairytale" aesthetic that incoporates storybook and fairytale characters and motifs into a slight run-down urban setting (one of the initial inspiration was Hong Kong in the 80/90s). The characters moved away from cloaks and tunics and more towards suits and ties.

<img src="DocImages/compiled-moodboard-3.jpeg" width="400"/>

As assets were being developed, I helped make sure that characters, enemies, and the environment aligned with the visual style that was created.

Color Palette Guidance - When originally deciding upon the game's look Danielle and I originally were going to go for a monochromatic look, but settled upon a muted color palette. We did this for readibility reasons as well as for thematic purposes (the environment is very drab, but the characters have splashes of color like Red Riding Hood's scarf and Goldilock's bow, representing light in a dark world). To ensure the art in the game aligned with the game's aesthetic and narrative, I helped with reviewing the assets being used to make sure they aligned with the game's theming. If I felt something was off, I discussed with Danielle to get her thoughts before deciding if any changes needed to be made. Any color changes were made directly on the image files themselves, saving us time on requiring in-engine color adjustments.
### Other Contributions
High Level Design - The game's original high level design consists of separate classes being handled by a global state machine. The intent was to break down the subsystems so that they are compartmentalized and can be worked on independently of each other. This system is based on portion of the course that covered different ways of creating systems (specifically the part that covered states).

<img src="DocImages/high-level-1.jpeg" width="500"/>

Code Review - Reviewed all code being PR'ed and made comments on changes that needed to be made to prevent potential problems compounding in the future.

Character Skill Design - Designed the skills for the characters. This ties into a few of the lectures in the course that covered game design.

<img src="DocImages/compiled-skills.jpeg" width="400"/>

UI/Gameplay Initial Concepts - Drew up the initial UI concepts and gameplay mockups. Worked with Adriano to create the first draft version of the UI.

<img src="DocImages/compiled-sketch.jpeg" width="400"/>
<img src="DocImages/compiled-ui.jpeg" width="400"/>
<img src="DocImages/ui-concept-3.jpeg" width="400"/>
<img src="DocImages/mockup-1.jpeg" width="400"/>

Subsystem Design - Designed the core gameplay subsystems (clashing, damage, skill selection, etc). The design of these systems are based on the 
lectures regarding game design for systems and mechanics. Designs were written out and sometimes given visual aids like clashing below:

<img src="DocImages/clash-concept-1.jpeg" width="400"/>
<img src="DocImages/clash-concept-2.jpeg" width="400"/>
<img src="DocImages/clash-concept-3.jpeg" width="400"/>

Skill Icons - Created the skill icons for both characters since no one had created them yet at the time.

Audio Asset Acquisition - Looked for audio assets since none had been found at the time. Found copyright free battle track.

---
    
For each team member, you shoudl work of your role and sub-role in terms of the content of the course. Please look at the role sections below for specific instructions for each role.

Below is a template for you to highlight items of your work. These provide the evidence needed for your work to be evaluated. Try to have at least four such descriptions. They will be assessed on the quality of the underlying system and how they are linked to course content. 

*Short Description* - Long description of your work item that includes how it is relevant to topics discussed in class. [link to evidence in your repository](https://github.com/dr-jam/ECS189L/edit/project-description/ProjectDocumentTemplate.md)

Here is an example:  
*Procedural Terrain* - The game's background consists of procedurally generated terrain produced with Perlin noise. The game can modify this terrain at run-time via a call to its script methods. The intent is to allow the player to modify the terrain. This system is based on the component design pattern and the procedural content generation portions of the course. [The PCG terrain generation script](https://github.com/dr-jam/CameraControlExercise/blob/513b927e87fc686fe627bf7d4ff6ff841cf34e9f/Obscura/Assets/Scripts/TerrainGenerator.cs#L6).

You should replay any **bold text** with your relevant information. Liberally use the template when necessary and appropriate.

Add addition contributions int he Other Contributions section.

## Main Roles ##

## Sub-Roles ##

## Other Contributions ##
