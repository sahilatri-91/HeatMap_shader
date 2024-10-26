using System.Collections;
using System.Collections.Generic;
using Palmmedia.ReportGenerator.Core.Reporting.Builders;
using Unity.VisualScripting;
using UnityEngine;

public class quad : MonoBehaviour
{

    Material mat;
    MeshRenderer mrenderer;

    float[] mpoints;
    int mHitCount;
    float mdelay;



    
    void Start()
    {

        mdelay = 3;

        mrenderer= GetComponent<MeshRenderer>();
        mat=mrenderer.material;
        
        mpoints=new float[32*3];  //32 point having x y z dirextions
    }

   
    void Update()
    {
        mdelay-=Time.deltaTime;
        if(mdelay<=0)
        {
            GameObject go=Instantiate(Resources.Load<GameObject>("sphere"));
            go.transform.position=new Vector3(Random.Range(-1f,1f),Random.Range(-1f,1f),Random.Range(-1f,1f));

            mdelay=0.5f;
        }
        
    } 
    private void OnCollisionEnter(Collision collision)
{
foreach(ContactPoint cp in collision.contacts){
    Debug.Log("collide with object: "+cp.otherCollider.gameObject.name);
    Destroy(cp.otherCollider.gameObject);
    
    Vector3 startRay=cp.point-cp.normal;
    Vector3 Raydir= cp.normal;

    Ray ray=new Ray(startRay,Raydir);
    RaycastHit hit;

    bool hitit=Physics.Raycast(ray,out hit,10.0f,LayerMask.GetMask("HeatMap Layer"));

    if(hitit)
    {
        Debug.Log("Hit object"+hit.collider.gameObject.name);
        Debug.Log("Hit Texture co-ordinate: "+hit.textureCoord.x+","+hit.textureCoord.y);
        addHitPoint(hit.textureCoord.x*4-2,hit.textureCoord.y*4-2);
    }

    Destroy(cp.otherCollider.gameObject);

}
}

public void addHitPoint(float xp,float yp)
{
    mpoints[mHitCount* 3]=xp;
    mpoints[mHitCount*3 +1]=yp;
    mpoints[mHitCount*3+2]= Random.Range(1f,3f);

    mHitCount++;
    mHitCount%= 32;

    mat.SetFloatArray("_Hits",mpoints);
    mat.SetInt("_hitcount",mHitCount);

    
}

}
