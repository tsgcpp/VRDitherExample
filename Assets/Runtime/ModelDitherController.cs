using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

namespace VRDitherExample
{
    public sealed class ModelDitherController : MonoBehaviour
    {
        [SerializeField] Slider _slider;
        [SerializeField] TMP_Dropdown _dropdown;
        [SerializeField] GameObject _modelRoot;

        private readonly List<Renderer> rendererCache = new(capacity: 16);

        readonly int AlphaPropId = Shader.PropertyToID("_Alpha");

        void OnEnable()
        {
            OnSliderValueChanged(_slider.value);
            ApplyShaderKeywords();
            
            _slider.onValueChanged.AddListener(OnSliderValueChanged);
            _dropdown.onValueChanged.AddListener(OnDropdownValueChanged);
        }

        void OnDisable()
        {
            _slider.onValueChanged.RemoveListener(OnSliderValueChanged);
        }

        void OnSliderValueChanged(float value)
        {
            _modelRoot.GetComponentsInChildren(rendererCache);
            foreach (var r in rendererCache)
            {
                foreach (var mat in r.materials)
                {
                    mat.SetFloat(AlphaPropId, value);
                }
            }
            rendererCache.Clear();
        }

        void OnDropdownValueChanged(int index)
        {
            var infoList = DitherInfoConstant.DitherInfoList;
            _modelRoot.GetComponentsInChildren(rendererCache);
            foreach (var r in rendererCache)
            {
                foreach (var mat in r.materials)
                {
                    var shader = mat.shader;
                    for (int i = 0; i < infoList.Count; ++i)
                    {
                        var info = infoList[i];
                        var keyword = new LocalKeyword(shader, info.Keyword);
                        if (i == index)
                        {
                            mat.EnableKeyword(keyword);
                        }
                        else
                        {
                            mat.DisableKeyword(keyword);
                        }
                    }
                }
            }
            rendererCache.Clear();
        }

        void ApplyShaderKeywords()
        {
            _dropdown.options = DitherInfoConstant.DitherInfoList
                .Select(i => new TMP_Dropdown.OptionData(i.Name))
                .ToList();
        }
    }
}
