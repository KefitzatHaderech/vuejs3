#!/bin/bash

# Function to check for command success and exit on failure
check_command() {
  if [ $? -ne 0 ]; then
    echo "Error: $1 failed to execute."
    exit 1
  fi
}

# Prompt user for the project name
read -p "Enter the project name: " PROJECT_NAME

# Validate the project name
if [ -z "$PROJECT_NAME" ]; then
  echo "Error: Project name cannot be empty."
  exit 1
fi

# Create a new Vue project
echo "Creating a new Vue 3 project..."
vue create $PROJECT_NAME -d
check_command "Vue project creation"

cd $PROJECT_NAME

# Install Tailwind CSS and its dependencies
echo "Installing Tailwind CSS..."
npm install tailwindcss postcss autoprefixer
check_command "Tailwind CSS installation"

# Initialize Tailwind CSS configuration
echo "Initializing Tailwind CSS configuration..."
npx tailwindcss init -p
check_command "Tailwind CSS initialization"

# Configure Tailwind CSS
echo "Configuring Tailwind CSS..."
TAILWIND_CONFIG="tailwind.config.js"
cat <<EOT > $TAILWIND_CONFIG
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOT

# Create Tailwind CSS file
echo "Creating Tailwind CSS file..."
mkdir -p src/assets
TAILWIND_CSS="src/assets/tailwind.css"
cat <<EOT > $TAILWIND_CSS
@tailwind base;
@tailwind components;
@tailwind utilities;
EOT

# Import Tailwind CSS in main.js
echo "Importing Tailwind CSS in main.js..."
MAIN_JS="src/main.js"
echo "import './assets/tailwind.css';" | cat - $MAIN_JS > temp && mv temp $MAIN_JS

# Create a simple component with native CSS
echo "Creating a simple Vue component..."
COMPONENT="src/components/HelloWorld.vue"
cat <<EOT > $COMPONENT
<template>
  <div class="p-6 max-w-sm mx-auto bg-white rounded-xl shadow-md space-y-4">
    <h1 class="text-2xl font-bold">Hello Vue 3 with Tailwind CSS</h1>
    <p class="text-gray-500">This is a simple example project.</p>
    <button class="btn">Click Me</button>
  </div>
</template>

<style scoped>
.btn {
  @apply bg-blue-500 text-white font-bold py-2 px-4 rounded;
  transition: background-color 0.3s ease;
}

.btn:hover {
  background-color: #3b82f6;
}
</style>

<script>
export default {
  name: 'HelloWorld',
};
</script>
EOT

# Modify App.vue to use the new component
echo "Updating App.vue to use the HelloWorld component..."
APP_VUE="src/App.vue"
cat <<EOT > $APP_VUE
<template>
  <div id="app">
    <HelloWorld />
  </div>
</template>

<script>
import HelloWorld from './components/HelloWorld.vue';

export default {
  name: 'App',
  components: {
    HelloWorld
  }
};
</script>

<style>
/* Additional global styles can go here */
</style>
EOT

# Delete the default logo.png file
echo "Deleting the default logo.png file..."
LOGO_FILE="src/assets/logo.png"
if [ -f "$LOGO_FILE" ]; then
  rm $LOGO_FILE
  check_command "Deleting logo.png"
fi

# Run the server to test the setup
echo "Starting the development server..."
npm run serve

echo "Project setup complete and server running! Visit the provided URL to see your project."

# End of script
