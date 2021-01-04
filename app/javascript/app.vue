<template>
  <div id="app">
    <forum-register/>
  </div>
</template>

<script>
import ForumRegister from 'components/forum_register/forum_register'
export default {
  props: ["forumId"],
  components: {
    ForumRegister
  }
}
</script>

