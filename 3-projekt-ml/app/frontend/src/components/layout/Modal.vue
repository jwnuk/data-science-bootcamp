<template>
  <TransitionRoot appear :show="open" as="template">
    <Dialog as="div" @close="closeModal">
      <div :class="$style['dialog']">
        <div :class="$style['dialog-wrapper']">
          <TransitionChild
            as="template"
            :enter="$style['animation-enter']"
            :enter-from="$style['opacity-0']"
            :enter-to="$style['opacity-100']"
            :leave="$style['animation-leave']"
            :leave-from="$style['opacity-100']"
            :leave-to="$style['opacity-0']">
            <DialogOverlay :class="$style['dialog-overlay']"/>
          </TransitionChild>

          <span :class="$style['dialog-hidden']" aria-hidden="true">
            &#8203;
          </span>

          <TransitionChild
            as="template"
            :enter="$style['animation-enter']"
            :enter-from="$style['animation-out']"
            :enter-to="$style['animation-in']"
            :leave="$style['animation-leave']"
            :leave-from="$style['animation-in']"
            :leave-to="$style['animation-out']">
            <div :class="$style['dialog-box']">
              <DialogTitle
                as="h3"
                :class="$style['dialog-title']">
                <slot name="header"></slot>
              </DialogTitle>
              <div :class="$style['dialog-box-description']">
                <slot name="content"></slot>
              </div>

              <div class="mt-4">
                <button
                  type="button"
                  @click="closeModal"
                  :class="$style['dialog-button']">
                  <slot name="close-button-content"></slot>
                </button>
              </div>
            </div>
          </TransitionChild>
        </div>
      </div>
    </Dialog>
  </TransitionRoot>
</template>

<script>
import {
  TransitionRoot,
  TransitionChild,
  Dialog,
  DialogOverlay,
  DialogTitle,
} from '@headlessui/vue';

export default {
  name: 'LayoutModal',
  props: {
    open: Boolean,
  },
  emits: ['update:open'],
  components: {
    TransitionRoot,
    TransitionChild,
    Dialog,
    DialogOverlay,
    DialogTitle,
  },
  methods: {
    closeModal() {
      this.$emit('update:open', false);
    },
  },
};
</script>

<style lang="scss" module>
.animation-enter {
  transition-duration: 300ms;
  transition-timing-function: cubic-bezier(0, 0, 0.2, 1);
}

.animation-out {
  opacity: 0;
  transform: scale(0.95);
}

.animation-in {
  opacity: 1;
  transform: scale(1);
}

.animation-leave {
  transition-duration: 200ms;
  transition-timing-function: cubic-bezier(0.4, 0, 1, 1);
}

.opacity-0 {
  opacity: 0;
}

.opacity-100 {
  opacity: 1;
}

.dialog {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  z-index: 10;
  overflow-y: auto;

  &-wrapper {
    min-height: 100vh;
    padding: 0 1rem;
    text-align: center;
  }

  &-overlay {
    position: fixed;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    pointer-events: none;
    background-color: rgba(17, 17, 17, 0.4);
    z-index: -1;
  }

  &-hidden {
    display: inline-block;
    height: 100vh;
    vertical-align: middle;
  }

  &-box {
    display: inline-block;
    width: 100%;
    box-sizing: border-box;
    max-width: 28rem;
    padding: 1.5rem;
    margin: 2rem 0;
    overflow: hidden;
    text-align: left;
    vertical-align: middle;
    transition-property: all;
    transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
    transition-duration: 150ms;
    background-color: #fff;
    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
    border-radius: 1rem;
    font-family: 'VT323', monospace;
  }

  &-title {
    font-size: 1.125rem;
    line-height: 1.5rem;
    color: #111827;
    padding: 0;
    margin: 0;
  }

  &-description {
    margin-top: 0.5rem;

    p {
      font-size: 0.875rem;
      line-height: 1.25rem;
      color: #4b5563;
    }
  }

  &-button {
    display: inline-flex;
    justify-content: center;
    padding: 0.5rem 1rem;
    font-size: 1rem;
    color: #03b603;
    background: #cdffc6;
    border-color: transparent;
    border-radius: 0.375rem;
    cursor: pointer;
    letter-spacing: 2px;
    font-family: 'VT323', monospace;
  }
}
</style>
