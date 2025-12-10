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
    asdf
  ### Narrative Design
    asdf
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

Color Palette Guidance - I worked with Danielle to ensure the art in the game aligned with the palette that was decided upon (muted colors with clear grayscale values). Art was checked to make sure this aligned with the game's theming and any changes regarding color were made directly on the image files themselves, saving us time on requiring in-engine color adjustments. We were able to do this because we weren't doing anything related to lighting in the game itself.
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

Audio Asset Acquisition - Looked for audio assets since none had been found at the time.





    
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
