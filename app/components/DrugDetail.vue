<script>
export const TABS = {
  pi: "pi",
  if: "if"
}
</script>
<script setup>
const config = useRuntimeConfig()
const { data: PITableContents } = await useFetch(`${config.public.API_URL}/interview_form_table_contents?mode=PI`)
const { data: IFTableContents } = await useFetch(`${config.public.API_URL}/interview_form_table_contents?mode=IF`)

const props = defineProps({
  drug: {
    type: Object,
    required: true,
  }
})
const { drug } = toRefs(props)
const activeTab = ref(TABS.pi)
const piTableIndex = ref(null)
const ifTableIndex = ref(null)
const moveToTargetSection = (sectionId) => {
  const tab = sectionId.slice(0, 2).toLowerCase()
  activeTab.value = TABS[tab]
  if (activeTab.value === TABS.pi) {
    piTableIndex.value?.moveToTargetSection()
  } else if (activeTab.value === TABS.if) {
    ifTableIndex.value?.moveToTargetSection()
  }
}
const route = useRoute()
watch(
  () => route.query,
  (newQuery) => {
    if (newQuery.drugId === drug.value.pi_id || newQuery.drugId === drug.value.if_id) {
      moveToTargetSection(newQuery.sectionId)
    }
  }
)
</script>

<template>
  <div class="drugDetail">
    <span class="drugDetail_close" @click="$emit('closeDrug', drug)">×</span>
    <div class="drugDetail_titleSection">
      <p class="drugDetail_title">{{ drug.drug_name }}</p>
      <p class="drugDetail_subSection">
        <span class="drugDetail_subTitle">一般名</span>
        {{ drug.synonyms.map(synonym => synonym.value).join(',') }}
      </p>
      <p class="drugDetail_subSection">
        <span class="drugDetail_subTitle">薬効分類</span>
        {{ drug.therapeutic_classifications }}
      </p>
    </div>
    <div class="docsSection">
      <div class="docsSection_tabs">
        <div class="docsSection_tab docsSection_tab-pi" :class="{ '-active': activeTab === TABS.pi }"
          @click="activeTab = TABS.pi">添付文書
        </div>
        <div class="docsSection_tab docsSection_tab-if" :class="{ '-active': activeTab === TABS.if }"
          @click="activeTab = TABS.if">インタビューフォーム
        </div>
      </div>
      <div v-show="activeTab === TABS.pi" class="docsSection_content">
        <TableIndex :key="`pi_${drug.pi_id}`" :table-contents="PITableContents" :active-tab="activeTab" :type="TABS.pi"
          :drug-id="drug.pi_id" ref="piTableIndex" @move-to-target-section="moveToTargetSection" />
      </div>
      <div v-show="activeTab === TABS.if" class="docsSection_content">
        <TableIndex :key="`if_${drug.if_id}`" :table-contents="IFTableContents" :active-tab="activeTab" :type="TABS.if"
          :drug-id="drug.if_id" ref="ifTableIndex" @move-to-target-section="moveToTargetSection" />
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.drugDetail {
  background-color: #f7f7f7;
  color: #333333;
  padding: 24px 8px;
  border-radius: 14px;
  position: relative;

  &_close {
    position: absolute;
    font-size: 24px;
    right: 16px;
    top: 10px;
    cursor: pointer;
  }

  &_titleSection {
    padding: 0 22px;
    font-size: 12px;
  }

  &_title {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 12px;
  }

  &_subSection {
    margin-top: 6px;
  }

  &_subTitle {
    font-size: 10px;
  }

  &_subTitle {
    opacity: .5;
    font-weight: bold;
    margin-right: 2px;
    font-size: 10px;
  }

}

.docsSection {
  &_tabs {
    display: flex;
    width: 100%;
  }

  &_tab {
    width: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 13px;
    background-color: #e2e2e2;
    border-radius: 5px 5px 0 0;
    padding: 10px 0 12px;
    margin-top: 18px;
    cursor: pointer;

    &.-active {
      font-size: 14px;
      font-weight: bold;
      color: #ffffff;
    }

    &::before {
      content: '';
      width: 20px;
      height: 20px;
      display: block;
      margin-right: 4px;
      background-size: contain;
      background-repeat: no-repeat;
    }

    &-pi {
      &::before {
        background-image: url('assets/images/icon-PI.png');
      }

      &.-active {
        background-color: $pi_color;

        &::before {
          width: 16px;
          height: 16px;
          background-image: url('assets/images/icon-PI-white.png');
        }
      }
    }

    &-if {
      &::before {
        background-image: url('assets/images/icon-IF.png');
      }

      &.-active {
        background-color: $if_color;

        &::before {
          width: 16px;
          height: 16px;
          background-image: url('assets/images/icon-IF-white.png');
        }
      }
    }
  }

  &_content {
    padding: 10px 22px 0;
    background-color: #ffffff;
    border-radius: 0 0 5px 5px;
    height: calc(100vh - 282px);
    overflow: auto;
  }
}
</style>