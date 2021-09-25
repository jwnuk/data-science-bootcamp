<template>
  <a
    href="#"
    role="button"
    tabindex="0"
    :class="[$style['button'], { [$style['button--disabled']]: disabled }]"
    @click="handleButtonClick"
    @mouseover="isHover = true"
    @mouseleave="isHover = false">
    <div :class="{ [$style['button-hover-feedback']]: isHover }"></div>
    <div
      :class="$style['button-overlay']"
      :style="{ 'background-image': `url('${require('@/assets/button-sprite.png')}')` }"></div>
    <div :class="$style['button-text']">
      <slot></slot>
    </div>
  </a>
</template>

<script>
import { ref } from 'vue';

export default {
  name: 'LayoutButton',
  props: {
    disabled: Boolean,
  },
  setup() {
    const isHover = ref(false);

    return { isHover };
  },
  methods: {
    handleButtonClick(event) {
      event.preventDefault();
    },
  },
};
</script>

<style lang="scss" module>
.button {
  position: relative;
  width: 213px;
  height: 60px;
  display: inline-block;
  display: flex;
  justify-content: center;
  align-items: center;
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  text-decoration: none;
  padding: 10px;
  border-radius: 1px;

  &--disabled {
    cursor: wait;

    &:focus {
      box-shadow: none !important;
    }
  }

  &--disabled &-overlay {
    filter: grayscale(1);
  }

  &--disabled &-hover-feedback {
    display: none;
  }

  &-hover-feedback {
    width: 100%;
    height: calc(100% - 5px);
    position: absolute;
    background-color: #203c13;
    top: 5px;
    z-index: -1;
    transition-property: background-color;
    transition-timing-function: cubic-bezier(0.4, 0, 1, 1);
    transition-duration: 100ms;
  }

  &-overlay {
    position: absolute;
    top: -24px;
    right: 0;
    bottom: 0;
    left: 0;
    background-position: center;
    background-repeat: no-repeat;
    background-size: cover;
    image-rendering: pixelated;
  }

  &-text {
    font-size: 1.7rem;
    margin-top: 2px;
    text-transform: uppercase;
    letter-spacing: 4px;
    text-shadow: 2px 2px #4c4c4c;
    color: white;
  }

  &:focus {
    outline: 2px solid transparent;
    outline-offset: 2px;
    box-shadow: 0 0 0 4px #1c1c1c, 0 0 0 6px #e82f2f;
  }
}
</style>
