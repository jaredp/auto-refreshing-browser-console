auto-refreshing-browser-console
============================

Live reloaded output from command line apps in the browser

## Installation

```npm install auto-refreshing-browser-console -g```

## Usage

`$ consoleserver` from the root directory of your project, or

`$ consoleserver projectDir` to use projectDir as the root of your project

The program will print

```
Open http://localhost:7000 in Chrome
Press Ctrl+C to exit
```

Enter a command in the text field and hit execute.  The command will run and the output will be shown in the browser.

![sample](https://raw.github.com/jaredp/auto-refreshing-browser-console/master/screenshot.png)

Now the cool part: whenever you change a file in the project, the browser will automatically refresh the results from your command.