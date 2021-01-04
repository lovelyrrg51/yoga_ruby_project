<template>
  <div class="modal fade" :id="id" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <slot name="header">
            <h4 class="modal-title" id="largeModalLabel">Default Header</h4>
          </slot>
        </div>
        <div class="modal-body">
          <slot name="body">
            default body
          </slot>
        </div>
        <div class="modal-footer">
          <slot name="footer">
            <div class="shivyog-btn" data-dismiss="modal"><a href="javascript: void(0);"
                                                             class="btn cta_button_small bg-red waves-effect">Close</a>
            </div>
          </slot>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
  export default {
    props: {
      id: String
    },
    mounted() {
      $(`#${this.id}`).on('hidden.bs.modal', () => {
          this.$emit('closed')
      });
    }
  }
</script>
<style>

</style>