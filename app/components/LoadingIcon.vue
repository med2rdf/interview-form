<template>
  <div class="loadingIcon">
    <div class="loadingIcon_dot"></div>
  </div>
</template>

<style lang="scss">
.loadingIcon {
  margin: 12px 0;

  &_dot {
    width: 6px;
    aspect-ratio: 1;
    border-radius: 50%;
    animation: l5 1s infinite linear alternate;
    margin: 0 auto;
  }
}

@keyframes l5 {
  0% {
    box-shadow: 10px 0 $main_color, -10px 0 $main_pale_color;
    background: $main_color
  }

  33% {
    box-shadow: 10px 0 $main_color, -10px 0 $main_pale_color;
    background: $main_pale_color
  }

  66% {
    box-shadow: 10px 0 $main_pale_color, -10px 0 $main_color;
    background: $main_pale_color
  }

  100% {
    box-shadow: 10px 0 $main_pale_color, -10px 0 $main_color;
    background: $main_color
  }
}
</style>