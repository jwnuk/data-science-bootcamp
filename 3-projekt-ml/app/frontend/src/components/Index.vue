<template>
  <div :class="$style['wrapper']">
    <h1 :class="$style['app-name']">
      {{ localize('title') }}
    </h1>
    <h3 :class="$style['app-description']">
      {{ localize('app-description') }}
    </h3>
    <div :class="$style['language-switch']">
      <a
        href="#"
        role="button"
        tabindex="0"
        @click="(e) => switchLanguage(e, 'en')"
        :class="{ [$style['language-switch--selected']]: preferredLanguage == 'en' }">
        EN
      </a>
      <span>
        /
      </span>
      <a
        href="#"
        role="button"
        tabindex="0"
        @click="(e) => switchLanguage(e, 'pl')"
        :class="{ [$style['language-switch--selected']]: preferredLanguage == 'pl' }">
        PL
      </a>
    </div>
    <div :class="$style['form-grid']">
      <layout-dropdown
        v-for="mushroom in config"
        :key="mushroom.id"
        :label="getLabel(mushroom)"
        :small-label="getLabel(mushroom).length > 13"
        :wide="preferredLanguage === 'pl'"
        :items="addNoneValue(localizeValues(mushroom.values))"
        :suggestion="mushroom.suggestion ? localizeValues(mushroom.suggestion) : undefined"
        @update-item="(item) => onItemUpdate(mushroom, item)"/>
    </div>
    <layout-button style="margin: 3.5em 0" :disabled="loading" @click="submit">
      {{ localize('check') }}
    </layout-button>
    <layout-modal v-model:open="isResultsModalOpen">
      <template v-slot:header>
        {{ localize('prediction-results') }}
      </template>
      <template v-slot:content>
        <h4 v-html="predictionResult.poisonous
            ? localize('prediction-result-poisonous')
            : localize('prediction-result-not-poisonous')"></h4>
        <p>
          {{ localize('accuracy') }}: {{ (predictionResult.accuracy * 100).toFixed(2) }}%
        </p>
      </template>
      <template v-slot:close-button-content>
        {{ localize('close-modal') }}
      </template>
    </layout-modal>
  </div>
</template>

<script>
/* eslint-disable consistent-return, no-restricted-syntax */
import { onMounted, ref } from 'vue';

import LayoutButton from './layout/Button.vue';
import LayoutDropdown from './layout/Dropdown.vue';
import LayoutModal from './layout/Modal.vue';

const locals = {
  check: {
    pl: 'Sprawdź',
    en: 'Check',
  },
  title: {
    pl: 'E-Grzybiarz',
    en: 'E-Grzybiarz',
  },
  'app-description': {
    pl: 'Aplikacja do predykcji jadalności grzybów oparta o modele Machine Learning 🍄.',
    en: 'Aplikacja do predykcji jadalności grzybów oparta o modele Machine Learning 🍄.',
  },
  'prediction-results': {
    pl: 'Wyniki predykcji 💫',
    en: 'Prediction results 💫',
  },
  'prediction-result-poisonous': {
    pl: 'Grzyb moze byc <span style="color:#f00">trujacy</span>! 🍄',
    en: 'Mushroom may be <span style="color:#f00">poisonous</! 🍄',
  },
  'prediction-result-not-poisonous': {
    pl: 'Grzyb moze nie byc trujacy :)',
    en: 'Mushroom may not be poisonous :)',
  },
  'close-modal': {
    pl: 'Ok, dzięki',
    en: 'Ok, thanks',
  },
  accuracy: {
    pl: 'Prawdopodobieństwo',
    en: 'Accuracy',
  },
};

export default {
  name: 'PageIndex',
  components: {
    LayoutButton,
    LayoutDropdown,
    LayoutModal,
  },
  setup() {
    const config = ref(null);
    const selection = ref({});
    const loading = ref(true);
    const error = ref(null);
    const preferredLanguage = ref('en');
    const isResultsModalOpen = ref(false);
    const predictionResult = ref({ poisonous: -1, accuracy: 0 });

    function fetchConfig() {
      loading.value = true;
      return fetch('http://localhost:5000/api/config', {
        method: 'get',
        headers: {
          'content-type': 'application/json',
        },
      }).then((response) => {
        if (!response.ok) {
          const err = new Error(response.statusText);
          err.json = response.json();
          throw err;
        }

        return response.json();
      }).then((json) => {
        config.value = json;
      }).catch((err) => {
        error.value = err;

        if (err.json) {
          return err.json.then((json) => {
            error.value.message = json.message;
          });
        }
      })
        .then(() => {
          loading.value = false;
        });
    }

    onMounted(() => {
      fetchConfig();
    });

    return {
      config,
      selection,
      loading,
      error,
      preferredLanguage,
      isResultsModalOpen,
      predictionResult,
    };
  },
  methods: {
    switchLanguage(event, target) {
      event.preventDefault();
      this.preferredLanguage = target;
    },
    getLabel(mushroom) {
      switch (this.preferredLanguage) {
        case 'pl':
          return mushroom.name_pl;
        case 'en':
          return mushroom.name;
        default:
          return mushroom.name;
      }
    },
    localizeValues(values) {
      return values.map((value) => ({
        ...value,
        name: this.getLabel(value),
      }));
    },
    addNoneValue(values) {
      return [{ id: 'none', name: '?' }, ...values];
    },
    onItemUpdate(mushroom, item) {
      if (item.id === 'none') {
        this.selection[mushroom.id] = undefined;
        return;
      }

      this.selection[mushroom.id] = item.id;
    },
    submit() {
      console.log(this.selection);

      this.loading = true;

      return fetch('http://localhost:5000/api/predict', {
        method: 'post',
        body: JSON.stringify(this.selection),
        headers: {
          'content-type': 'application/json',
        },
      }).then((response) => {
        if (!response.ok) {
          const err = new Error(response.statusText);
          err.json = response.json();
          throw err;
        }

        return response.json();
      }).then((response) => {
        this.predictionResult = response;
        this.isResultsModalOpen = true;
      }).finally(() => {
        this.loading = false;
      });
    },
    localize(key) {
      return locals[key][this.preferredLanguage];
    },
  },
};
</script>

<style lang="scss" module>
.wrapper {
  max-width: 1024px;
  margin: 0 auto;
  display: flex;
  margin-top: 4em;
  flex-direction: column;
  align-items: center;
  color: #fff;
}

.app-name {
  font-size: 3rem;
  letter-spacing: 6px;
  margin: 0;
}

.app-description {
  font-size: 1.4rem;
  letter-spacing: 1px;
  max-width: 80%;
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  grid-gap: 1em 3rem;

  @media screen and (max-width: 768px) {
    grid-template-columns: 1fr 1fr;
  }

  @media screen and (max-width: 500px) {
    grid-template-columns: 1fr;
  }
}

.language-switch {
  font-size: 2.4rem;
  margin-bottom: 10px;

  a {
    text-decoration: none;
    color: #fff;
  }

  &--selected {
    color: rgb(28, 227, 10) !important;
  }
}
</style>
