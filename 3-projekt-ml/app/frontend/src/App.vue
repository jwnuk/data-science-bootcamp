<template>
  <div id="app">
    <page-index/>
  </div>
</template>

<script>
import PageIndex from './components/Index.vue';

export default {
  name: 'App',
  components: {
    PageIndex,
  },
};
</script>

<style lang="scss">
@import url('https://fonts.googleapis.com/css2?family=VT323&display=swap');

body {
  margin: 0;
  padding: 0;
  background-color: #1c1c1c;
}

#app {
  font-family: 'VT323', monospace;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #fff;
  min-height: 100vh;
}
</style>
