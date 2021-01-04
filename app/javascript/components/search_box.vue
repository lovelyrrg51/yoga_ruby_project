<template>
  <div class="row clearfix">
    <div class="col-sm-5">
      <div class="md-form">
        <input type="text" name="firstname" :id="`firstname_${id}`" class="form-control"
               v-model="criteria.firstName"
               @blur="handleTrigger"
               @keydown.enter.prevent="handleTrigger"
               :disabled="isFound"
        >
        <label :for="`firstname_${id}`">Enter First Name</label>
      </div>
    </div>
    <div class="col-sm-5">
      <div class="md-form">
        <input type="text" name="email_mobile_syid" :id="`email_${id}`" class="form-control"
               v-model="criteria.emailMobileSyid"
               @blur="handleTrigger"
               @keydown.enter.prevent="handleTrigger"
               :disabled="isFound"
        >
        <label :for="`email_${id}`">Enter Email/Mobile/SYID</label>
      </div>
    </div>
    <div class="col-sm-1">
      <div class="switch" data-trigger="hover" data-container="body" data-toggle="popover" data-placement="left"
           title="Member Status Switch"
           data-content="This switch will turn green if the member is already registered with us.">
        <label>
          <input type="checkbox" name="registration_status" class="registration_status"
                 :checked="isFound" @click="handleSwitch"
          >
          <span class="lever switch-col-green"></span>
        </label>
      </div>
      <!--<i class="material-icons red">error</i>-->
    </div>
    <div class="col-sm-1" v-if="memberCount>1" key="delete">
      <a href="#" rel="tooltip" data-placement="top" title="Delete" class="remove_field"
         @click="remove" data-turbolinks="false">
        <span class="remove_btn col-red"><i class="material-icons">close</i></span>
      </a>
    </div>
    <div class="col-sm-1" v-else key="no-delete">
      &nbsp;
    </div>
  </div>
</template>
<script>
  import { mapGetters } from 'vuex'
  export default {
    props: ["id", "isFound"],
    data: function () {
      return {
        criteria: {
          firstName: '',
          emailMobileSyid: '',
        }
      }
    },
    computed: {
      eligibleForSearch() {
        return !!this.criteria.firstName && !!this.criteria.emailMobileSyid
      },
      ...mapGetters(['memberCount'])
    },
    methods: {
      handleTrigger: function () {
        if (this.eligibleForSearch)
          this.$emit('triggered', this.criteria)
      },
      handleSwitch: function (event) {
        if (this.isFound) {
          this.resetCriteria()
          this.$emit('switchoff')
        } else {
          event.preventDefault();
          if(this.eligibleForSearch)
            this.$emit('switchon', this.criteria)
        }
      },
      remove: function (event) {
        event.preventDefault();
        this.$emit('remove')
      },
      resetCriteria: function () {
        const initCriteria = {
          firstName: '',
          emailMobileSyid: '',
        }
        Object.assign(this.criteria, initCriteria)
      }
    },
    watch: {
      'criteria.firstName': function (val) {
        const id = this.id
        this.$store.commit('updateSearchFirstName', {id, val});
      },
      'criteria.emailMobileSyid': function (val) {
        const id = this.id
        this.$store.commit('updateSearchEmailOrMobileOrSyid', {id, val});
      }
    }
  }
</script>