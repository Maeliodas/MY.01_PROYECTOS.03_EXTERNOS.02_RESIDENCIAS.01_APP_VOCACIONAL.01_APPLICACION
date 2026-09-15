import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../avatar/presentation/providers/avatar_provider.dart';
import '../../../catalog/domain/models/catalog_models.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});
  @override ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _nameController;
  String? _stateId, _municipalityId, _schoolId;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _nameController = TextEditingController(text: profile?.name ?? '');
    _stateId = profile?.stateId;
    _municipalityId = profile?.municipalityId;
    _schoolId = profile?.schoolId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = ref.read(profileProvider);
      if (p == null) return;
      if (p.avatarConfig.avatarPath.startsWith('/') || p.avatarConfig.avatarPath.contains('emulated')) {
        ref.read(avatarProvider.notifier).selectCustomPhoto(p.avatarConfig.avatarPath);
      } else {
        ref.read(avatarProvider.notifier).selectAvatar(p.avatarConfig.avatarPath);
      }
    });
  }

  @override void dispose(){ _nameController.dispose(); super.dispose(); }

  Future<void> _pickGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 88);
    if (picked != null) ref.read(avatarProvider.notifier).selectCustomPhoto(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(profileProvider);
    final avatar = ref.watch(avatarProvider);
    final statesAsync = ref.watch(statesProvider);
    final municipalitiesAsync = _stateId == null ? const AsyncData<List<Municipality>>([]) : ref.watch(municipalitiesProvider(_stateId!));
    final schoolsAsync = _municipalityId == null ? const AsyncData<List<School>>([]) : ref.watch(schoolsByMunicipalityProvider(_municipalityId));
    if (current == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final local = avatar.avatarPath.startsWith('/') || avatar.avatarPath.contains('emulated');
    final image = local ? Image.file(File(avatar.avatarPath), fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.person,size:54)) : Image.asset(avatar.avatarPath, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.person,size:54));

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(22,8,22,30), children: [
        Center(child: Container(width:104,height:104,padding:const EdgeInsets.all(4),decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:AppColors.primary,width:3)),child:ClipOval(child:image))),
        const SizedBox(height:14),
        const Text('Avatar', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height:10),
        SizedBox(height:78, child: ListView.separated(scrollDirection:Axis.horizontal,itemCount:defaultAvatars.length,separatorBuilder:(_,__)=>const SizedBox(width:9),itemBuilder:(_,i){final path=defaultAvatars[i];final active=avatar.avatarPath==path;return InkWell(onTap:()=>ref.read(avatarProvider.notifier).selectAvatar(path),borderRadius:BorderRadius.circular(16),child:Container(width:68,padding:const EdgeInsets.all(3),decoration:BoxDecoration(borderRadius:BorderRadius.circular(16),border:Border.all(color:active?AppColors.primary:Theme.of(context).colorScheme.outline,width:active?3:1)),child:ClipRRect(borderRadius:BorderRadius.circular(12),child:Image.asset(path,fit:BoxFit.cover))));})),
        const SizedBox(height:10),
        OutlinedButton.icon(onPressed:_pickGallery,icon:const Icon(Icons.photo_library_outlined),label:const Text('Elegir desde galería o fotos')),
        const SizedBox(height:22),
        TextFormField(controller:_nameController,textCapitalization:TextCapitalization.words,decoration:const InputDecoration(labelText:'Nombre',prefixIcon:Icon(Icons.person_outline_rounded))),
        const SizedBox(height:14),
        statesAsync.when(data:(states)=>DropdownButtonFormField<String>(isExpanded:true,initialValue:states.any((x)=>x.id==_stateId)?_stateId:null,decoration:const InputDecoration(labelText:'Estado',prefixIcon:Icon(Icons.location_on_outlined)),items:states.map((x)=>DropdownMenuItem(value:x.id,child:Text(x.name,maxLines:1,overflow:TextOverflow.ellipsis))).toList(),onChanged:(v)=>setState((){_stateId=v;_municipalityId=null;_schoolId=null;})),loading:()=>const LinearProgressIndicator(),error:(_,__)=>const Text('No se pudieron cargar los estados.')),
        const SizedBox(height:14),
        municipalitiesAsync.when(data:(items)=>DropdownButtonFormField<String>(isExpanded:true,initialValue:items.any((x)=>x.id==_municipalityId)?_municipalityId:null,decoration:const InputDecoration(labelText:'Municipio',prefixIcon:Icon(Icons.map_outlined)),items:items.map((x)=>DropdownMenuItem(value:x.id,child:Text(x.name,maxLines:1,overflow:TextOverflow.ellipsis))).toList(),onChanged:(v)=>setState((){_municipalityId=v;_schoolId=null;})),loading:()=>const LinearProgressIndicator(),error:(_,__)=>const Text('No se pudieron cargar los municipios.')),
        const SizedBox(height:14),
        schoolsAsync.when(data:(items)=>DropdownButtonFormField<String>(isExpanded:true,initialValue:items.any((x)=>x.id==_schoolId)?_schoolId:null,decoration:const InputDecoration(labelText:'Escuela de procedencia',prefixIcon:Icon(Icons.school_outlined)),items:items.map((x)=>DropdownMenuItem(value:x.id,child:Text(x.name,maxLines:1,overflow:TextOverflow.ellipsis))).toList(),onChanged:(v)=>setState(()=>_schoolId=v)),loading:()=>const LinearProgressIndicator(),error:(_,__)=>const Text('No se pudieron cargar las escuelas.')),
        const SizedBox(height:28),
        PrimaryButton(text:'Guardar cambios',icon:Icons.save_outlined,onPressed:_stateId==null||_municipalityId==null||_schoolId==null?null:() async {
          final states=await ref.read(statesProvider.future); final municipalities=await ref.read(municipalitiesProvider(_stateId!).future); final schools=await ref.read(schoolsByMunicipalityProvider(_municipalityId).future);
          final st=states.firstWhere((x)=>x.id==_stateId); final mun=municipalities.firstWhere((x)=>x.id==_municipalityId); final school=schools.firstWhere((x)=>x.id==_schoolId);
          final updated=UserProfile(id:current.id,name:_nameController.text.trim().isEmpty?current.name:_nameController.text.trim(),age:current.age,gender:current.gender,stateId:st.id,state:st.name,municipalityId:mun.id,municipality:mun.name,schoolId:school.id,school:school.name,speaksLanguages:current.speaksLanguages,languageIds:current.languageIds,languagesList:current.languagesList,avatarConfig:ref.read(avatarProvider),createdAt:current.createdAt);
          await ref.read(profileProvider.notifier).saveProfile(updated); if(context.mounted) context.pop();
        }),
      ])),
    );
  }
}
