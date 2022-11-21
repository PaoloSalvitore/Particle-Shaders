using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HealthMan : MonoBehaviour
{
    private Material healthBarMat;

    public float health;
    // Start is called before the first frame update
    void Start()
    {
        healthBarMat = GetComponent<Material>();
    }

    // Update is called once per frame
    
    void Update()
    {
        healthBarMat.SetFloat("_Health",health);
    }
    
}
