<template>
  <div class="appWrapper">
    <slot />
  </div>
</template>

<style lang="scss">
html {
  background-color: $main_color;
}

.appWrapper {
  width: 100vw;
  color: #ffffff;
  box-sizing: border-box;
}
</style>
