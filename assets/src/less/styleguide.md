# Styleguide & Coding standards

Make sure to comment your css declarations like this to have them included in this living styleguide:
	/*
	Textarea

	It's a textarea.

	Markup:
	<textarea>This is content</textarea>

	Styleguide forms.textarea
	*/

	textarea {
		background: #eee;
	}

The css structure is inspired by SMACSS:
http://smacss.com/book/categorizing

Formatting code is as well inspired by SMACSS:
http://smacss.com/book/formatting

Follow this order to keep the properties clean and easy to use:
* Mixins
* Box
* Border
* Background
* Text
* Other

Example:
	.component {
		.mixin(); // mixin setting more then one attribute

		display: block;
		height: 200px;
		width: 200px;
		float: left;
		position: relative;

		border-radius: 10px;
		border: 1px solid #333;

		.box-shadow(10px 10px 5px #888);
		background-color: #fff;

		font-size: 12px;
		text-transform: uppercase;
	}

For modular css naming conventions please follow:
http://smacss.com/book/type-module

DISCLAMER: However we will use the name "component" instead of "module".

Follow this order to keep the component clean and easy to use:
* Component
  * Component modifiers
  * Media queries
* Sub components

Example:
	.component {
		// Component properties

		&.component-modifier {
			// Modifier properties
		}

		@media @mobileOnly {
			// Mobile properties for the component
		}
	}

	.component-sub {
		// Sub component properties
	}
