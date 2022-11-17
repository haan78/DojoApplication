<div class="header">
    <h2>Ankara Kendo Ön Kayıt Formu</h2>
</div>
<div class="body">

    <div class="form">

        <div class="column">

            <div class="item">
                <label style="width: 100%">
                    <span class="labelinfo">Ad/Soyad</span>
                    <input name="ad" type="text" placeholder="Ad/Soyad" autocomplete="off" />
                </label>
            </div>


            <div class="item">
                <label class="labelinfo">
                    <span>Doğum Tarihi</span>
                    <input name="dogum" type="date" placeholder="Doğum Tarihi" autocomplete="off" />

                </label>
            </div>


            <div class="item">
                <label class="labelinfo">
                    <span>Cinsiyet</span>
                    <select name="cinsiyet">
                        <option value="">[Seçiniz]</option>
                        <option value="KADIN">KADIN</option>
                        <option value="ERKEK">ERKEK</option>
                    </select>
                </label>
            </div>

        </div>


        <div class="item">
            <span class="labelinfo">Fotoğraf(isteğe bağlı)</span>
            <div data-comp="upload" data-name="foto"></div>
            <span class="labelinfo">Yüzününzün net bir şekilde gösteren, 3Mb`dan küçük bir fotoğraf</span>
        </div>
        <div class="item">
            <label style="cursor: pointer;width: 100%;"><input type="checkbox" name="ogrenci" onchange="" />Öğrenciyim(yüksek lisans ve doktora hariç)</label>
        </div>

        <div class="item">
            <label style="cursor: pointer;width: 100%;"><input type="checkbox" name="saglik" onchange="" />Eforlu spor yapmama engel bir sağlık problemim yoktur.</label>
        </div>

        <div class="item">
            <label style="cursor: pointer;width: 100%;"><input type="checkbox" name="onay" onchange="" />Yukarıda belirttiğim bilgilerin doğruluğunu onaylıyorum.</label>
        </div>

        <div class="item">
            <div class="h-captcha" data-sitekey="<?php echo $HCAPTCHA_SITEKEY; ?>"></div>
        </div>

        <div class="item">
            <button type="button" class="button" onclick=""><i class="fa fa-paper-plane" aria-hidden="true"></i>&nbsp;Kayıt Ol</button>
        </div>

    </div>


    <div class="text">

        <img src="./assets/basvuru.png" style="width: 100%;" />
        <fieldset>
            <legend>Bu formu kimler doldurmalı?</legend>
            <p>
                Bu kayıt form, daha öncesinde ankara kendo bünyesinde daha önce en az bir kendo antrenmanı yapmış kişiler içindir.
                Eğer daha öncesinde hiç kendo antrenmanı yapmadıysanız lütfen ücretsiz ilk tanıtım antrenmanınıza katılın.
                Antrenman sonunda bu kayıt formunun tarafınıza gönderilmesini istiyebilirsiniz.
                <br /><br />
                Eğer hala okumadıysanız lüften bu roemu doldurmadan önce aşağıdaki yazıları okuyun.
            <ul>
                <li><a href="//www.ankarakendo.com/uyelik-aidati">Üyelik Aidatı</a></li>
                <li><a href="//www.ankarakendo.com/calisma-kurallari">Çalışma Kuralları</a></li>
            </ul>

            </p>
        </fieldset>
        <fieldset>
            <legend>Bu kayıt formundaki bilgiler neden gerekli?</legend>
            <p>
            <ul>
                <li>
                    <p>Ad/Soyad size
                        hitap edebilmemiz için gereklidir.</p>
                </li>
                <li>
                    <p>E-Posta adresi
                        sizinle irtibata geçmek ve elektronik ortamda kimlik
                        doğrulaması yapabilmek için gereklidir. Bu sayede size özel üye biligi ekranınıza ulaşabilirsiniz.</p>
                </li>
                <li>
                    <p>Doğum tarihi ve
                        cinsiyetiniz katılacağınız turnuva ve sınavlarda kategori ve
                        sıralamalarının belirlenmesinde kullanılmaktadır. Ayrıca çalışmalar 13 yaş ve üzeri kişiler içindir.
                        Bu doğrulamayı yapmak için de doğum tarihinizi bilmemeiz gerekiyor.</p>
                </li>
                <li>
                    <p>Sağlık durumunuz. Kendo çalışmaları bazı hallerde gerçekten yorucu ve zorlayıcı olabilmektedir. Ayrıca bazen fiziksel temas içermektedir.
                        Bu nedenle yüksek efor harcarken veya sert temas halinde sorun olabilecek, kalp-damar, koah, kronik yüksek veya düşünk tansyon, belfıtığı, kemik erimesi vb. sağlık sorunlarınız varsa önceden bilmemiz önemli.</p>
                </li>
                <li>
                    <p>Fotoğraf
                        katıldığınız antrenmanlarda yoklamanın hızlı bir şekilde
                        alınabilmesi için gereklidir.</p>
                </li>
                <li>
                    <p>Öğrencilik durumunuz. Kulübümüzde öğrencilere indirimli üyelik uyuglanmaktadır.</p>

                </li>
            </ul>
            </p>
        </fieldset>
        <fieldset>
            <legend>Bu bilgileri başka kimle paylaşacaksınız?</legend>
            <p>Sisteme girmiş olduğunuz bilgiler. Ankara Kendo Iaido derneği sorumluluğundadadır. Üçüncü taraflarla paylaşılmayacaktır.</p>
        </fieldset>
        <fieldset>
            <legend>Üyelik nasıl tamamlanacak?</legend>
            <p>
                Bu formu gönderdiğinizde e-posta adresinizi doğrulayabilmek için otomatik bir doğrulama eposta alacaksınız.
                E-postadaki bağlantıyı tıklayarak doğrulamayaı gerçekleştiriniz. (<i>Bu işlem 24 saat içerisinde yapılmazsa doğrulama geçersiz olacaktır. Formun tekrar doldurulması gerekecektir.</i>)
            </p>
        </fieldset>
    </div>
</div>
</div>