<script>
</script>
<script setup>
import DrugDetail from '~/components/DrugDetail.vue';

const config = useRuntimeConfig()
const { data } = await useFetch(`${config.public.API_URL}/interview_form_drug_names`)
const drugList = ref(data)
const letters = ['ア', 'カ', 'サ', 'タ', 'ナ', 'ハ', 'マ', 'ヤ', 'ラ', 'ワ']
const usedIds = new Set();
drugList.value = drugList.value.map(drug => {
  const firstChar = drug.drug_name.charAt(0);
  if (letters.includes(firstChar) && !usedIds.has(firstChar)) {
    usedIds.add(firstChar);
    drug.id = firstChar
  }
  return drug
})
const originalDrugList = ref([...drugList.value])

const selectedDrugs = ref([])
const clickDrugName = drug => {
  if (selectedDrugs.value.some(selectedDrug => selectedDrug.if_id === drug.if_id)) {
    selectedDrugs.value = selectedDrugs.value.filter(selectedDrug => selectedDrug.if_id !== drug.if_id)
    return
  }
  selectedDrugs.value.push(drug)
}

const isSideBarOpen = ref(true)
const searchTargets = ref([
  {
    label: '薬剤名',
    key: 'drug_name',
    selected: true
  },
  {
    label: '一般名',
    key: 'synonyms',
    selected: false
  },
  {
    label: '薬効分類',
    key: 'therapeutic_classifications',
    selected: false
  }
])
const selectedSearchTarget = computed(() => searchTargets.value.find(target => target.selected))
const selectTarget = key => {
  searchTargets.value.forEach(target => {
    if (target.key === key) {
      target.selected = true
    } else {
      target.selected = false
    }
    isPulldownShown.value = false
  })
}
const isPulldownShown = ref(false)

const textSearchInput = ref()
const filterDisplayedDrug = () => {
  drugList.value = originalDrugList.value.filter(drug => {
    if (Array.isArray(drug[selectedSearchTarget.value.key])) {
      return drug[selectedSearchTarget.value.key].some(val => val.value?.includes(textSearchInput.value))
    } else {
      return drug[selectedSearchTarget.value.key]?.includes(textSearchInput.value)
    }
  })
}
</script>

<template>
  <div class="wholeWrapper">
    <div v-if="selectedDrugs.length > 0" class="toggleButton" :class="{ 'toggleButton-close': !isSideBarOpen }"
      @click="isSideBarOpen = !isSideBarOpen">
    </div>
    <aside class="sideBar" :class="{ 'sideBar-close': !isSideBarOpen, 'sideBar-full': selectedDrugs.length < 1 }">
      <img src="~assets/images/logo.png" alt="Interview Form Viewer" class="sideBar_logo">
      <DrugList :drug-list="drugList" :selected-drugs="selectedDrugs" @clickDrugName="clickDrugName" />
    </aside>
    <main class="mainContent" :class="{ 'mainContent-full': !isSideBarOpen }">
      <form class="formWrapper" :class="{ 'formWrapper-full': selectedDrugs.length < 1 }">
        <div class="formWrapper_searchTarget" @click="isPulldownShown = !isPulldownShown">{{ selectedSearchTarget.label
          }}</div>
        <div v-if="isPulldownShown" class="formWrapper_searchTargetPulldown">
          <p v-for="target in searchTargets" :key="target.key" class="formWrapper_searchTargetLabel" @click="
      selectTarget(target.key)">{{ target.label }}</p>
        </div>
        <input type="text" class="formWrapper_input" v-model="textSearchInput" @input="filterDisplayedDrug">
      </form>
      <div class="drugDetailList">
        <DrugDetail v-for="drug in selectedDrugs" :key="drug.if_id" :drug="drug" class="drugDetailList_card"
          :class="{ 'drugDetailList_card-single': selectedDrugs.length === 1 }" />
      </div>
      <div class="selectedDrugsSummary">
        <p v-for="selectedDrug in selectedDrugs" :key="selectedDrug.if_id" class="selectedDrugsSummary_name">
          {{ selectedDrug.drug_name }}
          <span class="selectedDrugsSummary_close" @click="clickDrugName(selectedDrug)">×</span>
        </p>
      </div>
      <div class="lettersIndex">
        <template v-for="(letter, index) in letters">
          <a :href="`#${letter}`" class="lettersIndex_letter">{{ letter }}</a>
          <span v-if="index !== letters.length - 1" class="lettersIndex_point">・</span>
        </template>
      </div>
    </main>
  </div>
</template>


<style lang="scss" scoped>
.wholeWrapper {
  position: relative;
  display: flex;
}

.sideBar {
  width: 244px;
  min-width: 244px;
  padding: 26px 0 0 20px;
  border-right: 1px solid #ffffff;
  position: relative;
  overflow: hidden;

  &-close {
    width: 0;
    min-width: 0;
  }

  &-full {
    width: 100%;
    border-right: 0;
  }

  &_logo {
    width: 182px;
    margin: 0 auto;
  }
}

.mainContent {
  padding: 22px 22px 0;
  width: calc(100vw - 265px);
  box-sizing: border-box;

  &-full {
    width: calc(100vw - 20px);
  }
}

.formWrapper {
  margin-bottom: 20px;
  position: relative;
  color: $main_color;
  font-size: 14px;
  font-weight: bold;

  &_searchTarget {
    position: absolute;
    top: 0;
    left: 0;
    width: 110px;
    box-sizing: border-box;
    height: 32px;
    border-radius: 20px 0 0 20px;
    border-right: 1px solid $main_color;
    background-color: #e5f3f6;
    z-index: 10;
    display: flex;
    align-items: center;
    cursor: pointer;
    padding: 0 22px;

    &::after {
      content: "";
      display: inline-block;
      border: 5px solid transparent;
      border-top: 5px solid #2e4d66;
      position: absolute;
      top: 13px;
      right: 12px;
    }
  }

  &_searchTargetPulldown {
    position: absolute;
    top: 34px;
    left: 0;
    width: 110px;
    border-radius: 10px;
    background-color: #e5f3f6;
    box-shadow: 0 2px 6px rgba(0, 0, 0, .5);
    padding: 8px 22px;
    box-sizing: border-box;
  }

  &_searchTargetLabel {
    cursor: pointer;
    margin: 18px 0;
  }

  &_input {
    width: 100%;
    height: 32px;
    border-radius: 20px;
    border: 0;
    box-sizing: border-box;
    padding-left: 120px;

  }

  &-full {
    position: absolute;
    width: calc(100% - 310px);
    right: 24px;
  }
}

.drugDetailList {
  display: flex;
  overflow: auto;
  max-height: calc(100vh - 112px);

  &_card {
    width: 50%;
    min-width: 510px;

    &-single {
      width: 100%;
    }

    &+& {
      margin-left: 14px;
    }
  }
}

.toggleButton {
  position: absolute;
  top: 50px;
  left: 250px;
  width: 32px;
  height: 32px;
  border-radius: 20px;
  background-color: #ffffff;
  cursor: pointer;
  z-index: 10;

  &::after {
    content: '';
    position: absolute;
    top: 34%;
    left: 40%;
    width: 6px;
    height: 6px;
    display: inline-blockck;
    border-top: 3px solid $main_color;
    border-left: 3px solid $main_color;
    transform: rotate(-45deg);
  }

  &-close {
    left: 5px;

    &::after {
      left: 33%;
      transform: rotate(135deg);
    }
  }
}

.selectedDrugsSummary {
  display: flex;
  height: 40px;
  align-items: center;
  position: absolute;
  bottom: 0;

  &_name {
    font-size: 12px;

    &+& {
      &::before {
        content: '/';
        margin: 0 16px;
      }
    }
  }

  &_close {
    font-size: 14px;
    margin-left: 8px;
    cursor: pointer;
  }
}

.lettersIndex {
  writing-mode: vertical-rl;
  position: absolute;
  right: 20px;
  top: 50%;
  transform: translateY(-50%);
  white-space: nowrap;

  &_letter {
    color: #ffffff;
    text-decoration: none;
  }

  &_point {
    margin: 10px 0;
  }
}
</style>