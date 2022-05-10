# CommonMatlabFunctions
## Summary
This repository contains general-purpose MATLAB functions. They are generally for reading from excel 
documents and/or plotting. Its commit history is mostly nonsense.


## Coding Practices
Coding practices are derived mainly from Google's Python Style guide, which is in close agreement with other Python repositories.
http://google.github.io/styleguide/pyguide.html
https://visualgit.readthedocs.io/en/latest/pages/naming_convention.html
Originally they were based off of somebody's MATLAB style guidelines, but those use CamelCase, and also MATLAB coding practices are less understandable than code coming from the Python community.
	matlab_style_guidelines.pdf from http://www.datatool.com/prod02.htm 
via matlabcentral 
	http://www.mathworks.com/matlabcentral/fileexchange/2529-matlab-programming-style-guidelines

Rules (1, 2, etc.) are followed "strictly" while guidelines (G1 etc.) are followed "loosely". I apologize for inconsistencies.

1. Write the documentation (class diagram, control loop, psuedocode, etc.) first.

2. Variable names (AND FUNCTIONS) should be in all_lowercase_with_underscores. Exception: constants as GLOBAL_CONSTANT_NAME, classes as ClassName, and exceptions as ExceptionName. Acronyms should be avoided. Ex: use "is_usa_specific" instead of "isUSASpecific". 
*Prior to Summer 2019, the lab mostly used CamelCase. Dylan decided to follow Google Python Style guide, and has been very glad of the change. As the maintainer of this repository, he switched to all_lowercase_with_underscores.*

3. Modularize by using functions. Also, use sections (matlab -> %%[code...]) to separate logical chunks.

4. Complex conditional expressions should be avoided. Introduce temporary logical variables instead.

5. Use Smart Indent before every commit.

6. Comments should consisely add information to the code. Write comments at the same time as the code. Address why or how rather than what.

7. Whitespace: after every comma, around every operator (a + b = 6), after comments (code = other_code % a comment) and a line after every logical chunk. Two lines at the end of every "section". One line at end of file.


G1. Structures can be used to avoid long lists of input or output arguments. MATLAB's inputParser class is useful for dealing with long lists of input arguments. (Also, a function used by only one other function should be packaged as its subfunction in the same file.)

G2. Whitespace: Surround special symbols by spaces (=, &, | etc.). Add white space between logical units of a block. Blocks should be separated by more than one blank line, or the comment symbol followed by a repeated character such as * or -.

G3. Function header comments should consisely describe inputs, outputs, and any side effects, such as plot generation. The last function header comment should restate the function line. This allows the user to glance at the help printout and see the input and output argument usage. Add a blank line between header comments that should be printed and other header comments.
