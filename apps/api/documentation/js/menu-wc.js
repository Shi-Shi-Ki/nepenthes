'use strict';

customElements.define('compodoc-menu', class extends HTMLElement {
    constructor() {
        super();
        this.isNormalMode = this.getAttribute('mode') === 'normal';
    }

    connectedCallback() {
        this.render(this.isNormalMode);
    }

    render(isNormalMode) {
        let tp = lithtml.html(`
        <nav>
            <ul class="list">
                <li class="title">
                    <a href="index.html" data-type="index-link">@nepenthes/api documentation</a>
                </li>

                <li class="divider"></li>
                ${ isNormalMode ? `<div id="book-search-input" role="search"><input type="text" placeholder="Type to search"></div>` : '' }
                <li class="chapter">
                    <a data-type="chapter-link" href="index.html"><span class="icon ion-ios-home"></span>Getting started</a>
                    <ul class="links">
                                <li class="link">
                                    <a href="overview.html" data-type="chapter-link">
                                        <span class="icon ion-ios-keypad"></span>Overview
                                    </a>
                                </li>

                            <li class="link">
                                <a href="index.html" data-type="chapter-link">
                                    <span class="icon ion-ios-paper"></span>
                                        README
                                </a>
                            </li>
                                <li class="link">
                                    <a href="dependencies.html" data-type="chapter-link">
                                        <span class="icon ion-ios-list"></span>Dependencies
                                    </a>
                                </li>
                                <li class="link">
                                    <a href="properties.html" data-type="chapter-link">
                                        <span class="icon ion-ios-apps"></span>Properties
                                    </a>
                                </li>

                    </ul>
                </li>
                    <li class="chapter modules">
                        <a data-type="chapter-link" href="modules.html">
                            <div class="menu-toggler linked" data-bs-toggle="collapse" ${ isNormalMode ?
                                'data-bs-target="#modules-links"' : 'data-bs-target="#xs-modules-links"' }>
                                <span class="icon ion-ios-archive"></span>
                                <span class="link-name">Modules</span>
                                <span class="icon ion-ios-arrow-down"></span>
                            </div>
                        </a>
                        <ul class="links collapse " ${ isNormalMode ? 'id="modules-links"' : 'id="xs-modules-links"' }>
                            <li class="link">
                                <a href="modules/ApplicationModule.html" data-type="entity-link" >ApplicationModule</a>
                                <li class="chapter inner">
                                    <div class="simple menu-toggler" data-bs-toggle="collapse" ${ isNormalMode ?
                                        'data-bs-target="#injectables-links-module-ApplicationModule-89f45673411392113c81d4eb9514204d62d9ebbaa1c9d40dff7fbdfe7d402244510d5be8af4ec45f05464f29f5ee38cd59d3a26dc564e90d804d7d22994b8a24"' : 'data-bs-target="#xs-injectables-links-module-ApplicationModule-89f45673411392113c81d4eb9514204d62d9ebbaa1c9d40dff7fbdfe7d402244510d5be8af4ec45f05464f29f5ee38cd59d3a26dc564e90d804d7d22994b8a24"' }>
                                        <span class="icon ion-md-arrow-round-down"></span>
                                        <span>Injectables</span>
                                        <span class="icon ion-ios-arrow-down"></span>
                                    </div>
                                    <ul class="links collapse" ${ isNormalMode ? 'id="injectables-links-module-ApplicationModule-89f45673411392113c81d4eb9514204d62d9ebbaa1c9d40dff7fbdfe7d402244510d5be8af4ec45f05464f29f5ee38cd59d3a26dc564e90d804d7d22994b8a24"' :
                                        'id="xs-injectables-links-module-ApplicationModule-89f45673411392113c81d4eb9514204d62d9ebbaa1c9d40dff7fbdfe7d402244510d5be8af4ec45f05464f29f5ee38cd59d3a26dc564e90d804d7d22994b8a24"' }>
                                        <li class="link">
                                            <a href="injectables/DeleteEventUseCaseService.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >DeleteEventUseCaseService</a>
                                        </li>
                                        <li class="link">
                                            <a href="injectables/SyncCalendarUseCaseService.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >SyncCalendarUseCaseService</a>
                                        </li>
                                        <li class="link">
                                            <a href="injectables/UpsertEventUseCaseService.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >UpsertEventUseCaseService</a>
                                        </li>
                                    </ul>
                                </li>
                            </li>
                            <li class="link">
                                <a href="modules/AppModule.html" data-type="entity-link" >AppModule</a>
                                    <li class="chapter inner">
                                        <div class="simple menu-toggler" data-bs-toggle="collapse" ${ isNormalMode ?
                                            'data-bs-target="#controllers-links-module-AppModule-a47c89762f5a031c5af2e4ae801f1754096eded1200d41c487240714ac75b264b635201c13597939fddbbff74d8f26d77f0ddbd95756ed3074689d4d543d09d7"' : 'data-bs-target="#xs-controllers-links-module-AppModule-a47c89762f5a031c5af2e4ae801f1754096eded1200d41c487240714ac75b264b635201c13597939fddbbff74d8f26d77f0ddbd95756ed3074689d4d543d09d7"' }>
                                            <span class="icon ion-md-swap"></span>
                                            <span>Controllers</span>
                                            <span class="icon ion-ios-arrow-down"></span>
                                        </div>
                                        <ul class="links collapse" ${ isNormalMode ? 'id="controllers-links-module-AppModule-a47c89762f5a031c5af2e4ae801f1754096eded1200d41c487240714ac75b264b635201c13597939fddbbff74d8f26d77f0ddbd95756ed3074689d4d543d09d7"' :
                                            'id="xs-controllers-links-module-AppModule-a47c89762f5a031c5af2e4ae801f1754096eded1200d41c487240714ac75b264b635201c13597939fddbbff74d8f26d77f0ddbd95756ed3074689d4d543d09d7"' }>
                                            <li class="link">
                                                <a href="controllers/AppController.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >AppController</a>
                                            </li>
                                        </ul>
                                    </li>
                                <li class="chapter inner">
                                    <div class="simple menu-toggler" data-bs-toggle="collapse" ${ isNormalMode ?
                                        'data-bs-target="#injectables-links-module-AppModule-a47c89762f5a031c5af2e4ae801f1754096eded1200d41c487240714ac75b264b635201c13597939fddbbff74d8f26d77f0ddbd95756ed3074689d4d543d09d7"' : 'data-bs-target="#xs-injectables-links-module-AppModule-a47c89762f5a031c5af2e4ae801f1754096eded1200d41c487240714ac75b264b635201c13597939fddbbff74d8f26d77f0ddbd95756ed3074689d4d543d09d7"' }>
                                        <span class="icon ion-md-arrow-round-down"></span>
                                        <span>Injectables</span>
                                        <span class="icon ion-ios-arrow-down"></span>
                                    </div>
                                    <ul class="links collapse" ${ isNormalMode ? 'id="injectables-links-module-AppModule-a47c89762f5a031c5af2e4ae801f1754096eded1200d41c487240714ac75b264b635201c13597939fddbbff74d8f26d77f0ddbd95756ed3074689d4d543d09d7"' :
                                        'id="xs-injectables-links-module-AppModule-a47c89762f5a031c5af2e4ae801f1754096eded1200d41c487240714ac75b264b635201c13597939fddbbff74d8f26d77f0ddbd95756ed3074689d4d543d09d7"' }>
                                        <li class="link">
                                            <a href="injectables/AppService.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >AppService</a>
                                        </li>
                                    </ul>
                                </li>
                            </li>
                            <li class="link">
                                <a href="modules/CommonModule.html" data-type="entity-link" >CommonModule</a>
                                <li class="chapter inner">
                                    <div class="simple menu-toggler" data-bs-toggle="collapse" ${ isNormalMode ?
                                        'data-bs-target="#injectables-links-module-CommonModule-4705af0181a8b0d6bc5c945bcc4527b0c101110893538613e77e69a6d65537e92a2e3079e85917960f21b95de87c5d44333ec1bbae2faa18effc765e8d69a9dc"' : 'data-bs-target="#xs-injectables-links-module-CommonModule-4705af0181a8b0d6bc5c945bcc4527b0c101110893538613e77e69a6d65537e92a2e3079e85917960f21b95de87c5d44333ec1bbae2faa18effc765e8d69a9dc"' }>
                                        <span class="icon ion-md-arrow-round-down"></span>
                                        <span>Injectables</span>
                                        <span class="icon ion-ios-arrow-down"></span>
                                    </div>
                                    <ul class="links collapse" ${ isNormalMode ? 'id="injectables-links-module-CommonModule-4705af0181a8b0d6bc5c945bcc4527b0c101110893538613e77e69a6d65537e92a2e3079e85917960f21b95de87c5d44333ec1bbae2faa18effc765e8d69a9dc"' :
                                        'id="xs-injectables-links-module-CommonModule-4705af0181a8b0d6bc5c945bcc4527b0c101110893538613e77e69a6d65537e92a2e3079e85917960f21b95de87c5d44333ec1bbae2faa18effc765e8d69a9dc"' }>
                                        <li class="link">
                                            <a href="injectables/UtilsService.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >UtilsService</a>
                                        </li>
                                    </ul>
                                </li>
                            </li>
                            <li class="link">
                                <a href="modules/InfrastructureModule.html" data-type="entity-link" >InfrastructureModule</a>
                                <li class="chapter inner">
                                    <div class="simple menu-toggler" data-bs-toggle="collapse" ${ isNormalMode ?
                                        'data-bs-target="#injectables-links-module-InfrastructureModule-183aafaeb3974196a86d418a1c1b4213875fbaa03b19dafa62dc845bc94b49899174d332c03a159d7205517f1876690797adb7a23b7cd32d1e20f8fcf681bc9d"' : 'data-bs-target="#xs-injectables-links-module-InfrastructureModule-183aafaeb3974196a86d418a1c1b4213875fbaa03b19dafa62dc845bc94b49899174d332c03a159d7205517f1876690797adb7a23b7cd32d1e20f8fcf681bc9d"' }>
                                        <span class="icon ion-md-arrow-round-down"></span>
                                        <span>Injectables</span>
                                        <span class="icon ion-ios-arrow-down"></span>
                                    </div>
                                    <ul class="links collapse" ${ isNormalMode ? 'id="injectables-links-module-InfrastructureModule-183aafaeb3974196a86d418a1c1b4213875fbaa03b19dafa62dc845bc94b49899174d332c03a159d7205517f1876690797adb7a23b7cd32d1e20f8fcf681bc9d"' :
                                        'id="xs-injectables-links-module-InfrastructureModule-183aafaeb3974196a86d418a1c1b4213875fbaa03b19dafa62dc845bc94b49899174d332c03a159d7205517f1876690797adb7a23b7cd32d1e20f8fcf681bc9d"' }>
                                        <li class="link">
                                            <a href="injectables/GoogleCalendarAdapterService.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >GoogleCalendarAdapterService</a>
                                        </li>
                                    </ul>
                                </li>
                            </li>
                            <li class="link">
                                <a href="modules/PresentationModule.html" data-type="entity-link" >PresentationModule</a>
                                    <li class="chapter inner">
                                        <div class="simple menu-toggler" data-bs-toggle="collapse" ${ isNormalMode ?
                                            'data-bs-target="#controllers-links-module-PresentationModule-7e7253c212deeb5f0b12ef91e4fcc02f81458103f4caba1b130992b4715275f7484ffc58aa009d7e6f9a67a6e3c03e0d28a59f859088e8b65abbe9f4799d7093"' : 'data-bs-target="#xs-controllers-links-module-PresentationModule-7e7253c212deeb5f0b12ef91e4fcc02f81458103f4caba1b130992b4715275f7484ffc58aa009d7e6f9a67a6e3c03e0d28a59f859088e8b65abbe9f4799d7093"' }>
                                            <span class="icon ion-md-swap"></span>
                                            <span>Controllers</span>
                                            <span class="icon ion-ios-arrow-down"></span>
                                        </div>
                                        <ul class="links collapse" ${ isNormalMode ? 'id="controllers-links-module-PresentationModule-7e7253c212deeb5f0b12ef91e4fcc02f81458103f4caba1b130992b4715275f7484ffc58aa009d7e6f9a67a6e3c03e0d28a59f859088e8b65abbe9f4799d7093"' :
                                            'id="xs-controllers-links-module-PresentationModule-7e7253c212deeb5f0b12ef91e4fcc02f81458103f4caba1b130992b4715275f7484ffc58aa009d7e6f9a67a6e3c03e0d28a59f859088e8b65abbe9f4799d7093"' }>
                                            <li class="link">
                                                <a href="controllers/WebhookController.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >WebhookController</a>
                                            </li>
                                        </ul>
                                    </li>
                            </li>
                </ul>
                </li>
                    <li class="chapter">
                        <div class="simple menu-toggler" data-bs-toggle="collapse" ${ isNormalMode ? 'data-bs-target="#classes-links"' :
                            'data-bs-target="#xs-classes-links"' }>
                            <span class="icon ion-ios-paper"></span>
                            <span>Classes</span>
                            <span class="icon ion-ios-arrow-down"></span>
                        </div>
                        <ul class="links collapse " ${ isNormalMode ? 'id="classes-links"' : 'id="xs-classes-links"' }>
                            <li class="link">
                                <a href="classes/WebhookHandlePayloadDto.html" data-type="entity-link" >WebhookHandlePayloadDto</a>
                            </li>
                        </ul>
                    </li>
                        <li class="chapter">
                            <div class="simple menu-toggler" data-bs-toggle="collapse" ${ isNormalMode ? 'data-bs-target="#injectables-links"' :
                                'data-bs-target="#xs-injectables-links"' }>
                                <span class="icon ion-md-arrow-round-down"></span>
                                <span>Injectables</span>
                                <span class="icon ion-ios-arrow-down"></span>
                            </div>
                            <ul class="links collapse " ${ isNormalMode ? 'id="injectables-links"' : 'id="xs-injectables-links"' }>
                                <li class="link">
                                    <a href="injectables/DeleteEventUseCaseService.html" data-type="entity-link" >DeleteEventUseCaseService</a>
                                </li>
                                <li class="link">
                                    <a href="injectables/SyncCalendarUseCaseService.html" data-type="entity-link" >SyncCalendarUseCaseService</a>
                                </li>
                                <li class="link">
                                    <a href="injectables/UpsertEventUseCaseService.html" data-type="entity-link" >UpsertEventUseCaseService</a>
                                </li>
                            </ul>
                        </li>
                    <li class="chapter">
                        <div class="simple menu-toggler" data-bs-toggle="collapse" ${ isNormalMode ? 'data-bs-target="#guards-links"' :
                            'data-bs-target="#xs-guards-links"' }>
                            <span class="icon ion-ios-lock"></span>
                            <span>Guards</span>
                            <span class="icon ion-ios-arrow-down"></span>
                        </div>
                        <ul class="links collapse " ${ isNormalMode ? 'id="guards-links"' : 'id="xs-guards-links"' }>
                            <li class="link">
                                <a href="guards/WebhookGuard.html" data-type="entity-link" >WebhookGuard</a>
                            </li>
                        </ul>
                    </li>
                    <li class="chapter">
                        <div class="simple menu-toggler" data-bs-toggle="collapse" ${ isNormalMode ? 'data-bs-target="#interfaces-links"' :
                            'data-bs-target="#xs-interfaces-links"' }>
                            <span class="icon ion-md-information-circle-outline"></span>
                            <span>Interfaces</span>
                            <span class="icon ion-ios-arrow-down"></span>
                        </div>
                        <ul class="links collapse " ${ isNormalMode ? ' id="interfaces-links"' : 'id="xs-interfaces-links"' }>
                            <li class="link">
                                <a href="interfaces/GoogleServiceAccountKey.html" data-type="entity-link" >GoogleServiceAccountKey</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/ICalendarApi.html" data-type="entity-link" >ICalendarApi</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/NormalizedCalendarEvent.html" data-type="entity-link" >NormalizedCalendarEvent</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/PrivateProps.html" data-type="entity-link" >PrivateProps</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/SyncResult.html" data-type="entity-link" >SyncResult</a>
                            </li>
                        </ul>
                    </li>
                    <li class="chapter">
                        <div class="simple menu-toggler" data-bs-toggle="collapse" ${ isNormalMode ? 'data-bs-target="#miscellaneous-links"'
                            : 'data-bs-target="#xs-miscellaneous-links"' }>
                            <span class="icon ion-ios-cube"></span>
                            <span>Miscellaneous</span>
                            <span class="icon ion-ios-arrow-down"></span>
                        </div>
                        <ul class="links collapse " ${ isNormalMode ? 'id="miscellaneous-links"' : 'id="xs-miscellaneous-links"' }>
                            <li class="link">
                                <a href="miscellaneous/functions.html" data-type="entity-link">Functions</a>
                            </li>
                            <li class="link">
                                <a href="miscellaneous/typealiases.html" data-type="entity-link">Type aliases</a>
                            </li>
                            <li class="link">
                                <a href="miscellaneous/variables.html" data-type="entity-link">Variables</a>
                            </li>
                        </ul>
                    </li>
                        <li class="chapter">
                            <a data-type="chapter-link" href="routes.html"><span class="icon ion-ios-git-branch"></span>Routes</a>
                        </li>
                    <li class="chapter">
                        <a data-type="chapter-link" href="coverage.html"><span class="icon ion-ios-stats"></span>Documentation coverage</a>
                    </li>
                    <li class="divider"></li>
                    <li class="copyright">
                        Documentation generated using <a href="https://compodoc.app/" target="_blank" rel="noopener noreferrer">
                            <img data-src="images/compodoc-vectorise.png" class="img-responsive" data-type="compodoc-logo">
                        </a>
                    </li>
            </ul>
        </nav>
        `);
        this.innerHTML = tp.strings;
    }
});