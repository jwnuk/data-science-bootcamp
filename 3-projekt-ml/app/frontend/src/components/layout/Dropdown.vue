<template>
  <Listbox v-model="selectedItem">
    <div :class="$style['dropdown-wrapper']">
      <ListboxButton
        as="a"
        role="button"
        tabindex="0"
        :class="[$style['dropdown'], { [$style['dropdown--wide']]: wide }]"
        v-slot="{ open }">
        <span
          :class="[
            $style['dropdown-label'],
            { [$style['dropdown-label--small']]: smallLabel },
            { [$style['dropdown-label--dense']]: dense }
          ]">
          {{ label }}:
        </span>
        <div
          :class="$style['dropdown-overlay']"
          :style="{
            'background-image': wide
              ? `url('${require('@/assets/button-sprite-wide.png')}')`
              : `url('${require('@/assets/button-sprite.png')}')`
          }"></div>
        <span :class="$style['dropdown-text']">{{ selectedItem.name }}</span>
        <span
          :class="[$style['carot-down'], { [$style['carot-down--expanded']]: open }]"
          aria-hidden="true"/>
        <div
          v-if="suggestion && open"
          :class="$style['suggestion-box']">
          <div :class="$style['suggestion-box-title']"></div>
          <div
            :class="$style['suggestion-box-content']">
            <div
              v-for="item in suggestion"
              :key="item.id"
              :class="$style['suggestion-box-content-item']">
              <img
                :alt="item.name + ' illustration'"
                :src="item.image"
                :class="$style['suggestion-box-content-image']"/>
              <span :class="$style['suggestion-box-content-text']">
                {{ item.name }}
              </span>
            </div>
          </div>
        </div>
      </ListboxButton>

      <transition
        :leave-active-class="$style['transition']"
        :leave-from-class="$style['opacity-100']"
        :leave-to-class="$style['opacity-0']">
        <ListboxOptions :Class="$style['dropdown-list']">
          <ListboxOption
            v-slot="{ active, selected }"
            v-for="item in items"
            :key="item.name"
            :value="item"
            as="template">
            <li
              :class="[
                $style['dropdown-list-item'],
                { [$style['dropdown-list-item--active']]: active }
              ]">
              <span
                :class="[
                  selected ? 'font-medium' : 'font-normal',
                  $style['dropdown-list-item-text'],
                ]"
                >{{ item.name }}</span>
              <span
                v-if="selected"
                :class="$style['dropdown-list-item-checkmark']">
                ✓
              </span>
            </li>
          </ListboxOption>
        </ListboxOptions>
      </transition>
    </div>
  </Listbox>
</template>

<script>
import { ref } from 'vue';
import {
  Listbox,
  ListboxButton,
  ListboxOptions,
  ListboxOption,
} from '@headlessui/vue';

export default {
  name: 'LayoutDropdown',
  props: {
    label: String,
    items: Array,
    smallLabel: Boolean,
    dense: Boolean,
    wide: Boolean,
    suggestion: Array,
  },
  components: {
    Listbox,
    ListboxButton,
    ListboxOptions,
    ListboxOption,
  },
  setup(props) {
    const selectedItem = ref(props.items[0]);

    return {
      selectedItem,
    };
  },
  watch: {
    selectedItem(newItem) {
      this.$emit('updateItem', newItem);
    },
    items(items) {
      this.selectedItem = items.find((item) => item.id === this.selectedItem.id);
    },
  },
};
</script>

<style lang="scss" module>
$base-z-index: 0;

.opacity-0 {
  opacity: 0;
}

.opacity-100 {
  opacity: 100;
}

@keyframes fadeInUp {
  from {
    transform: translate3d(0, 40px, 0);
  }

  to {
    transform: translate3d(0, 0, 0);
    opacity: 1;
  }
}

.transition {
  transition-property:
    background-color, border-color, color, fill, stroke,
    opacity, box-shadow, transform, filter, backdrop-filter;
  transition-timing-function: cubic-bezier(0.4, 0, 1, 1);
  transition-duration: 100ms;
}

.suggestion-box {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  width: 100%;
  display: flex;
  flex-direction: column;
  z-index: $base-z-index + 40;
  overflow-x: auto;

  &-content {
    display: flex;
    flex-direction: row;
    background-color: #333;
    border-radius: 3px 0 0 3px;
    animation-name: fadeInUp;
    animation-duration: 0.15s;
    animation-fill-mode: both;
    cursor: default;
    overflow-x: auto;
    max-width: 768px;
    margin: 0 auto;

    &-item {
      display: flex;
      flex-direction: column;
      justify-content: center;
      text-align: center;
      padding: 1rem;
    }

    &-image {
      max-width: 84px;
      border-radius: 3px;
    }

    &-text {
      margin-top: 4px;
    }
  }
}

.dropdown {
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
  background-color: transparent;
  padding: 10px;
  border-radius: 1px;
  cursor: pointer;

  &--wide {
    width: 303px;
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

  &-label {
    position: absolute;
    left: 0;
    top: -1.205rem;
    padding: 0 5px;
    z-index: $base-z-index + 10;
    font-size: 1.66rem;
    text-transform: uppercase;
    text-shadow: 2px 2px rgba(#4c4c4c, 0.2);
    max-width: 75%;

    &--small {
      font-size: 1.2rem;
      top: -1.8rem;
    }

    &--dense {
      font-size: 1.3rem;
    }
  }

  &-text {
    font-size: 1.7rem;
    margin-top: 2px;
    text-transform: uppercase;
    letter-spacing: 4px;
    text-shadow: 2px 2px #4c4c4c;
    color: white;
    display: block;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  &-wrapper {
    position: relative;
    margin-top: 34px;
  }

  &-list {
    position: absolute;
    width: 100%;
    padding: 4px 0;
    margin-top: 4px;
    overflow: auto;
    font-size: 1rem;
    line-height: 1.5rem;
    background-color: #292929;
    border-radius: 0 0 2px 2px;
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
    max-height: 15rem;
    box-shadow: 0 0 0 1px rgba(#000, 0.05);
    color: white;
    z-index: $base-z-index + 20;

    &:focus {
      outline: none;
    }

    &-item {
      cursor: default;
      user-select: none;
      position: relative;
      padding: 8px 0;
      padding-left: 28px;
      padding-right: 16px;
      display: flex;
      flex-direction: row;

      &--active {
        background-color: #03b603;
      }

      &-text {
        display: block;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        text-transform: uppercase;
        font-size: 1.2rem;
      }

      &-checkmark {
        position: absolute;
        left: 0;
        display: flex;
        justify-items: center;
        padding-left: 12px;
      }
    }
  }

  &:focus {
    outline: 2px solid transparent;
    outline-offset: 2px;
    box-shadow: 0 0 0 4px #1c1c1c, 0 0 0 6px #e82f2f;
  }
}

.carot-down {
  background: url(
    'data:image/png;base64,' +
    'iVBORw0KGgoAAAANSUhEUgAAAAUAAAADCAYAAABbNsX4AAAAAXNSR0IArs4c6QAAAB1JREFUGFdj' +
    '/P///38GNMAI4iNLMIIATBFIAsYHAKmaDAA8JJADAAAAAElFTkSuQmCC'
  );
  background-repeat: no-repeat;
  background-size: cover;
  image-rendering: pixelated;
  width: 5px * 3;
  height: 3px * 3;
  position: absolute;
  top: calc(50% - 3px);
  right: 16px;
  pointer-events: none;

  &--expanded {
    transform: rotate(180deg);
  }
}
</style>
